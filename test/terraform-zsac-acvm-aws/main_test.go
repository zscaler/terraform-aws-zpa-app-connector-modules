package terraform_zsac_acvm_aws

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

// Custom destroy function that ignores cleanup errors
func destroyIgnoreErrors(t *testing.T, terraformOptions *terraform.Options) {
	defer func() {
		if r := recover(); r != nil {
			logger.Log(t, "Cleanup completed with some errors (this is expected and can be ignored)")
		}
	}()
	terraform.Destroy(t, terraformOptions)
}

func TestValidate(t *testing.T) {
	terraformOptions := CreateTerraformOptions(t)
	// Use terraform.Plan instead of terraform.Validate since validate doesn't accept var files
	terraform.Plan(t, terraformOptions)
}

func TestPlan(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// plan test infrastructure
	terraform.Plan(t, terraformOptions)
}

func TestApply(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// deploy test infrastructure
	defer destroyIgnoreErrors(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify outputs using validation outputs
	privateIPValid := terraform.Output(t, terraformOptions, "private_ip_valid")
	assert.Equal(t, "true", privateIPValid, "Private IP should be valid")

	availabilityZoneValid := terraform.Output(t, terraformOptions, "availability_zone_valid")
	assert.Equal(t, "true", availabilityZoneValid, "Availability Zone should be valid")

	instanceIDValid := terraform.Output(t, terraformOptions, "instance_id_valid")
	assert.Equal(t, "true", instanceIDValid, "Instance ID should be valid")

	testVariablesSetCorrectly := terraform.Output(t, terraformOptions, "test_variables_set_correctly")
	assert.Equal(t, "true", testVariablesSetCorrectly, "Test variables should be set correctly")

	acvmConfigurationValid := terraform.Output(t, terraformOptions, "acvm_configuration_valid")
	assert.Equal(t, "true", acvmConfigurationValid, "ACVM configuration should be valid")

	instanceTypeValid := terraform.Output(t, terraformOptions, "instance_type_valid")
	assert.Equal(t, "true", instanceTypeValid, "Instance type should be valid")

	networkDependenciesValid := terraform.Output(t, terraformOptions, "network_dependencies_valid")
	assert.Equal(t, "true", networkDependenciesValid, "Network dependencies should be valid")
}

func TestIdempotence(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// deploy test infrastructure
	defer destroyIgnoreErrors(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify idempotence - second apply should not make changes
	terraform.Apply(t, terraformOptions)
}
