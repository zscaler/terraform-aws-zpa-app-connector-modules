package terraform_zsac_network_aws

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

func TestApply(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// deploy test infrastructure
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify outputs using validation outputs
	vpcIdValid := terraform.Output(t, terraformOptions, "vpc_id_valid")
	assert.Equal(t, "true", vpcIdValid, "VPC ID should be valid")

	acSubnetIdsValid := terraform.Output(t, terraformOptions, "ac_subnet_ids_valid")
	assert.Equal(t, "true", acSubnetIdsValid, "AC Subnet IDs should be valid")

	acSubnetCountCorrect := terraform.Output(t, terraformOptions, "ac_subnet_count_correct")
	assert.Equal(t, "true", acSubnetCountCorrect, "AC Subnet count should be correct")

	acRouteTableIdsValid := terraform.Output(t, terraformOptions, "ac_route_table_ids_valid")
	assert.Equal(t, "true", acRouteTableIdsValid, "AC Route Table IDs should be valid")

	acRouteTableCountCorrect := terraform.Output(t, terraformOptions, "ac_route_table_count_correct")
	assert.Equal(t, "true", acRouteTableCountCorrect, "AC Route Table count should be correct")

	testVariablesSetCorrectly := terraform.Output(t, terraformOptions, "test_variables_set_correctly")
	assert.Equal(t, "true", testVariablesSetCorrectly, "Test variables should be set correctly")

	vpcCidrCorrect := terraform.Output(t, terraformOptions, "vpc_cidr_correct")
	assert.Equal(t, "true", vpcCidrCorrect, "VPC CIDR should be correct")

	azCountCorrect := terraform.Output(t, terraformOptions, "az_count_correct")
	assert.Equal(t, "true", azCountCorrect, "AZ count should be correct")

	// Verify actual outputs are not empty
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")

	acSubnetIds := terraform.OutputList(t, terraformOptions, "ac_subnet_ids")
	assert.Len(t, acSubnetIds, 2, "Should create 2 AC subnets")

	acRouteTableIds := terraform.OutputList(t, terraformOptions, "ac_route_table_ids")
	assert.Len(t, acRouteTableIds, 2, "Should create 2 AC route tables")
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

func TestNetworkWithCustomCIDR(t *testing.T) {
	// Test with custom VPC CIDR
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"aws_region":                  "us-west-2",
			"name_prefix":                 "test-network-custom",
			"resource_tag":                "custom-test",
			"vpc_cidr":                    "10.2.0.0/16",
			"az_count":                    2,
			"associate_public_ip_address": false,
			"byo_vpc":                     false,
			"byo_igw":                     false,
			"byo_ngw":                     false,
			"byo_subnets":                 false,
		},
		Logger:  logger.Default,
		Lock:    true,
		Upgrade: true,
	})

	// deploy test infrastructure
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify outputs
	vpcIdValid := terraform.Output(t, terraformOptions, "vpc_id_valid")
	assert.Equal(t, "true", vpcIdValid, "VPC ID should be valid")

	acSubnetIdsValid := terraform.Output(t, terraformOptions, "ac_subnet_ids_valid")
	assert.Equal(t, "true", acSubnetIdsValid, "AC Subnet IDs should be valid")

	acSubnetCountCorrect := terraform.Output(t, terraformOptions, "ac_subnet_count_correct")
	assert.Equal(t, "true", acSubnetCountCorrect, "AC Subnet count should be correct")

	// Verify actual outputs
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")

	acSubnetIds := terraform.OutputList(t, terraformOptions, "ac_subnet_ids")
	assert.Len(t, acSubnetIds, 2, "Should create 2 AC subnets")
}

func TestNetworkWithSingleAZ(t *testing.T) {
	// Test with single AZ
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"aws_region":                  "us-west-2",
			"name_prefix":                 "test-network-single-az",
			"resource_tag":                "single-az-test",
			"vpc_cidr":                    "10.3.0.0/16",
			"az_count":                    1,
			"associate_public_ip_address": false,
			"byo_vpc":                     false,
			"byo_igw":                     false,
			"byo_ngw":                     false,
			"byo_subnets":                 false,
		},
		Logger:  logger.Default,
		Lock:    true,
		Upgrade: true,
	})

	// deploy test infrastructure
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify outputs
	vpcIdValid := terraform.Output(t, terraformOptions, "vpc_id_valid")
	assert.Equal(t, "true", vpcIdValid, "VPC ID should be valid")

	acSubnetIdsValid := terraform.Output(t, terraformOptions, "ac_subnet_ids_valid")
	assert.Equal(t, "true", acSubnetIdsValid, "AC Subnet IDs should be valid")

	acSubnetCountCorrect := terraform.Output(t, terraformOptions, "ac_subnet_count_correct")
	assert.Equal(t, "true", acSubnetCountCorrect, "AC Subnet count should be correct")

	// Verify actual outputs
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")

	acSubnetIds := terraform.OutputList(t, terraformOptions, "ac_subnet_ids")
	assert.Len(t, acSubnetIds, 1, "Should create 1 AC subnet")
}
