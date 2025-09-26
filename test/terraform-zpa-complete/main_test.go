package terraform_zpa_complete

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func CreateTerraformOptions(t *testing.T) *terraform.Options {
	// define options for Terraform
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		VarFiles:     []string{"test.tfvars"},
		Logger:       logger.Default,
		Lock:         true,
		Upgrade:      true,
	})

	return terraformOptions
}

func TestValidate(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)
	// Use terraform.Plan instead of terraform.Validate since validate doesn't accept var files
	terraform.Plan(t, terraformOptions)
}

func TestPlan(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// Run terraform plan
	terraform.Plan(t, terraformOptions)
}

func TestApply(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// Schedule `terraform destroy` at the end of the test, to clean up the created resources.
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` and check the results.
	appConnectorGroupId := terraform.Output(t, terraformOptions, "app_connector_group_id")
	assert.NotEmpty(t, appConnectorGroupId, "App Connector Group ID should not be empty")

	provisioningKey := terraform.Output(t, terraformOptions, "provisioning_key")
	assert.NotEmpty(t, provisioningKey, "Provisioning Key should not be empty")

	// Log the outputs for verification
	t.Logf("App Connector Group ID: %s", appConnectorGroupId)
	t.Logf("Provisioning Key: %s", provisioningKey)
}
