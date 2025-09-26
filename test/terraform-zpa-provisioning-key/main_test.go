package terraform_zpa_provisioning_key

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func CreateTerraformOptions(t *testing.T) *terraform.Options {
	// define options for Terraform
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"enrollment_cert":                   "Connector",
			"provisioning_key_name":             "test-provisioning-key",
			"provisioning_key_enabled":          true,
			"provisioning_key_association_type": "CONNECTOR_GRP",
			"provisioning_key_max_usage":        "10",
			"app_connector_group_id":            "test-connector-group-id",
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

func TestValidate(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)
	// Initialize and then plan to ensure providers are downloaded
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

func TestPlan(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// Initialize and then plan test infrastructure
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

// TestApply is removed because it uses a fake App Connector Group ID which will always fail.
// Use TestApplyWithRealAppConnectorGroup or TestApplyWithRealAppConnectorGroupUsingZPAtt instead.

// TestIdempotence is removed because it uses a fake App Connector Group ID which will always fail.
// Use TestApplyWithRealAppConnectorGroup or TestApplyWithRealAppConnectorGroupUsingZPAtt instead.

// TestWithExistingProvisioningKey is removed because it uses a fake App Connector Group ID which will always fail.
// Use TestApplyWithRealAppConnectorGroup or TestApplyWithRealAppConnectorGroupUsingZPAtt instead.
