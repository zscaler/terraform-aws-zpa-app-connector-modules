package terraform_zpa_app_connector_group

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/zscaler/terraform-aws-zpa-app-connector-modules/test/internal/zpatt"
)

func TestZPAttEnhancedValidation(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	// Custom check function for ZPA-specific validations
	checkFunc := func(t *testing.T, terraformOptions *terraform.Options) {
		// Verify App Connector Group ID is valid
		appConnectorGroupId := terraform.Output(t, terraformOptions, "app_connector_group_id")
		assert.NotEmpty(t, appConnectorGroupId, "App Connector Group ID should not be empty")

		// Additional ZPA-specific validations can be added here
		t.Logf("App Connector Group ID: %s", appConnectorGroupId)
	}

	// Run enhanced ZPA test using ZPAtt utility
	zpatt.ZPATest(t, terraformOptions, checkFunc)
}

func TestZPAttLocationChange(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	// Test location change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_latitude":  "40.7128", // New York
		"app_connector_group_longitude": "-74.0060",
		"app_connector_group_location":  "New York, NY, USA",
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}

func TestZPAttVersionProfileChange(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	// Test version profile change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_version_profile_id": "2", // Change from "0" to "2"
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}

func TestZPAttDescriptionChange(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	// Test description change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_description": "Updated Test App Connector Group",
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}

func TestZPAttDNSQueryTypeChange(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	// Test DNS query type change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_dns_query_type": "IPV4_ONLY", // Change from "IPV4_IPV6"
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}

// Manual ZPAtt-style test without using the utility (for demonstration)
func TestManualZPAttStyle(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)

	// Schedule `terraform destroy` at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Initial apply
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	appConnectorGroupId := terraform.Output(t, terraformOptions, "app_connector_group_id")
	assert.NotEmpty(t, appConnectorGroupId, "App Connector Group ID should not be empty")

	// Test parameter change
	terraformOptions.Vars["app_connector_group_description"] = "Updated Description"

	// Plan the changes
	terraformOptions.PlanFilePath = "test.plan"
	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// ZPAtt-style validation: Check for recreate scenarios
	for _, resourceChange := range plan.ResourceChangesMap {
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

		// ZPAtt validation: Prevent recreate scenarios
		if hasDelete && hasCreate {
			t.Errorf("ZPA Resource about to be deleted and then created again. This likely introduces service disruption. Resource: %v", resourceChange.Address)
		}
	}

	// Apply the changes
	terraform.InitAndApply(t, terraformOptions)

	// Validate final state
	finalAppConnectorGroupId := terraform.Output(t, terraformOptions, "app_connector_group_id")
	assert.Equal(t, appConnectorGroupId, finalAppConnectorGroupId, "App Connector Group ID should not change")

	t.Logf("App Connector Group ID: %s", finalAppConnectorGroupId)
}
