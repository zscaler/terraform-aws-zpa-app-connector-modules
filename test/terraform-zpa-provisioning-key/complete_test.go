package terraform_zpa_provisioning_key

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func CreateTerraformOptionsWithRealACG(t *testing.T, appConnectorGroupId string) *terraform.Options {
	// define options for Terraform with real App Connector Group ID
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"enrollment_cert":                   "Connector",
			"provisioning_key_name":             "test-provisioning-key",
			"provisioning_key_enabled":          true,
			"provisioning_key_association_type": "CONNECTOR_GRP",
			"provisioning_key_max_usage":        "10",
			"app_connector_group_id":            appConnectorGroupId, // Use real ID
			"byo_provisioning_key":              false,
			"byo_provisioning_key_name":         "",
		},
		Logger:               logger.Default,
		Lock:                 true,
		Upgrade:              true,
		SetVarsAfterVarFiles: true,
	})

	return terraformOptions
}

func TestApplyWithRealAppConnectorGroup(t *testing.T) {
	// First, create an App Connector Group to get a real ID
	acgTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform-zpa-app-connector-group",
		VarFiles:     []string{"test.tfvars"},
		Logger:       logger.Default,
		Lock:         true,
		Upgrade:      true,
	})

	// Create the App Connector Group
	defer terraform.Destroy(t, acgTerraformOptions)
	terraform.InitAndApply(t, acgTerraformOptions)

	// Get the App Connector Group ID
	appConnectorGroupId := terraform.Output(t, acgTerraformOptions, "app_connector_group_id")
	assert.NotEmpty(t, appConnectorGroupId, "App Connector Group ID should not be empty")

	// Now create the Provisioning Key with the real App Connector Group ID
	pkTerraformOptions := CreateTerraformOptionsWithRealACG(t, appConnectorGroupId)
	defer terraform.Destroy(t, pkTerraformOptions)
	terraform.InitAndApply(t, pkTerraformOptions)

	// Verify the Provisioning Key was created successfully
	provisioningKey := terraform.Output(t, pkTerraformOptions, "provisioning_key")
	assert.NotEmpty(t, provisioningKey, "Provisioning Key should not be empty")

	// Log the results for verification
	t.Logf("App Connector Group ID: %s", appConnectorGroupId)
	t.Logf("Provisioning Key: %s", provisioningKey)
}

func TestApplyWithRealAppConnectorGroupUsingZPAtt(t *testing.T) {
	// This test demonstrates how to use the ZPAtt utility
	// First, create an App Connector Group to get a real ID
	acgTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform-zpa-app-connector-group",
		VarFiles:     []string{"test.tfvars"},
		Logger:       logger.Default,
		Lock:         true,
		Upgrade:      true,
	})

	// Create the App Connector Group
	defer terraform.Destroy(t, acgTerraformOptions)
	terraform.InitAndApply(t, acgTerraformOptions)

	// Get the App Connector Group ID
	appConnectorGroupId := terraform.Output(t, acgTerraformOptions, "app_connector_group_id")
	assert.NotEmpty(t, appConnectorGroupId, "App Connector Group ID should not be empty")

	// Now create the Provisioning Key with the real App Connector Group ID
	pkTerraformOptions := CreateTerraformOptionsWithRealACG(t, appConnectorGroupId)
	defer terraform.Destroy(t, pkTerraformOptions)
	terraform.InitAndApply(t, pkTerraformOptions)

	// Verify the Provisioning Key was created successfully
	provisioningKey := terraform.Output(t, pkTerraformOptions, "provisioning_key")
	assert.NotEmpty(t, provisioningKey, "Provisioning Key should not be empty")

	// Test parameter changes using ZPAtt-style approach
	// Change the provisioning key name
	pkTerraformOptions.Vars["provisioning_key_name"] = "test-provisioning-key-updated"

	// Plan the changes
	pkTerraformOptions.PlanFilePath = "test.plan"
	plan := terraform.InitAndPlanAndShowWithStruct(t, pkTerraformOptions)

	// Verify that changes are updates, not recreates
	for _, resourceChange := range plan.ResourceChangesMap {
		// Check that we're not recreating the resource
		hasDelete := false
		hasCreate := false
		for _, action := range resourceChange.Change.Actions {
			if action == "delete" {
				hasDelete = true
			}
			if action == "create" {
				hasCreate = true
			}
		}

		// If both delete and create are present, it's a recreate (bad for ZPA)
		if hasDelete && hasCreate {
			t.Errorf("ZPA Resource about to be deleted and then created again. This likely introduces service disruption. Resource: %v", resourceChange.Address)
		}
	}

	// Apply the changes
	terraform.InitAndApply(t, pkTerraformOptions)

	// Verify the updated Provisioning Key
	updatedProvisioningKey := terraform.Output(t, pkTerraformOptions, "provisioning_key")
	assert.NotEmpty(t, updatedProvisioningKey, "Updated Provisioning Key should not be empty")

	// Log the results for verification
	t.Logf("App Connector Group ID: %s", appConnectorGroupId)
	t.Logf("Updated Provisioning Key: %s", updatedProvisioningKey)
}
