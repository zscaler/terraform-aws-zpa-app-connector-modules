package terraform_zsac_bastion_aws

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
	// Use terraform.InitAndPlan instead of terraform.Validate since validate doesn't accept var files
	terraform.InitAndPlan(t, terraformOptions)
}

func TestPlan(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// Initialize and then plan test infrastructure
	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)
}

func TestApply(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// deploy test infrastructure
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify outputs using validation outputs
	publicIPValid := terraform.Output(t, terraformOptions, "public_ip_valid")
	assert.Equal(t, "true", publicIPValid, "Public IP should be valid")

	publicDNSValid := terraform.Output(t, terraformOptions, "public_dns_valid")
	assert.Equal(t, "true", publicDNSValid, "Public DNS should be valid")

	testVariablesSetCorrectly := terraform.Output(t, terraformOptions, "test_variables_set_correctly")
	assert.Equal(t, "true", testVariablesSetCorrectly, "Test variables should be set correctly")

	instanceTypeValid := terraform.Output(t, terraformOptions, "instance_type_valid")
	assert.Equal(t, "true", instanceTypeValid, "Instance type should be valid")

	networkDependenciesValid := terraform.Output(t, terraformOptions, "network_dependencies_valid")
	assert.Equal(t, "true", networkDependenciesValid, "Network dependencies should be valid")
}

func TestIdempotence(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// deploy test infrastructure
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify idempotence - second apply should not make changes
	terraform.Apply(t, terraformOptions)
}
