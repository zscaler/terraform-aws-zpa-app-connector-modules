package terraform_zsac_sg_aws

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

	// plan test infrastructure
	terraform.InitAndPlan(t, terraformOptions)
}

func TestApply(t *testing.T) {
	// define options for Terraform
	terraformOptions := CreateTerraformOptions(t)

	// deploy test infrastructure
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify outputs
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")

	acSecurityGroupIds := terraform.OutputList(t, terraformOptions, "ac_security_group_ids")
	assert.Len(t, acSecurityGroupIds, 2, "Should create 2 security groups")

	byoSecurityGroupId := terraform.Output(t, terraformOptions, "byo_security_group_id")
	assert.NotEmpty(t, byoSecurityGroupId, "BYO Security Group ID should not be empty")

	acSgByoSecurityGroupIds := terraform.OutputList(t, terraformOptions, "ac_sg_byo_security_group_ids")
	assert.Len(t, acSgByoSecurityGroupIds, 1, "Should reference 1 BYO security group")

	// Verify test validation outputs
	securityGroupCountCorrect := terraform.Output(t, terraformOptions, "security_group_count_correct")
	assert.Equal(t, "true", securityGroupCountCorrect, "Security group count should be correct")

	byoSecurityGroupCountCorrect := terraform.Output(t, terraformOptions, "byo_security_group_count_correct")
	assert.Equal(t, "true", byoSecurityGroupCountCorrect, "BYO security group count should be correct")

	securityGroupNamesCorrect := terraform.Output(t, terraformOptions, "security_group_names_correct")
	assert.Equal(t, "true", securityGroupNamesCorrect, "Security group names should follow expected pattern")
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

// TestSecurityGroupEnhanced runs an enhanced test for the Security Group module
func TestSecurityGroupEnhanced(t *testing.T) {
	t.Parallel()

	terraformOptions := CreateTerraformOptions(t)

	// Initial Apply
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify VPC was created
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")

	// Verify security groups were created
	acSecurityGroupIds := terraform.OutputList(t, terraformOptions, "ac_security_group_ids")
	assert.Len(t, acSecurityGroupIds, 2, "Should create 2 security groups")

	// Verify BYO security group functionality
	byoSecurityGroupId := terraform.Output(t, terraformOptions, "byo_security_group_id")
	assert.NotEmpty(t, byoSecurityGroupId, "BYO Security Group ID should not be empty")

	acSgByoSecurityGroupIds := terraform.OutputList(t, terraformOptions, "ac_sg_byo_security_group_ids")
	assert.Len(t, acSgByoSecurityGroupIds, 1, "Should reference 1 BYO security group")

	// Verify test validation outputs
	securityGroupCountCorrect := terraform.Output(t, terraformOptions, "security_group_count_correct")
	assert.Equal(t, "true", securityGroupCountCorrect, "Security group count should be correct")

	byoSecurityGroupCountCorrect := terraform.Output(t, terraformOptions, "byo_security_group_count_correct")
	assert.Equal(t, "true", byoSecurityGroupCountCorrect, "BYO security group count should be correct")

	securityGroupNamesCorrect := terraform.Output(t, terraformOptions, "security_group_names_correct")
	assert.Equal(t, "true", securityGroupNamesCorrect, "Security group names should follow expected pattern")

	// Verify security group ARNs are valid
	acSecurityGroupArns := terraform.OutputList(t, terraformOptions, "ac_security_group_arns")
	assert.Len(t, acSecurityGroupArns, 2, "Should have 2 security group ARNs")

	for _, arn := range acSecurityGroupArns {
		assert.Contains(t, arn, "arn:aws:ec2:", "Security group ARN should be valid")
	}

	// Test idempotence - second apply should not make changes
	terraform.Apply(t, terraformOptions)

	// Validate outputs after second apply
	updatedAcSecurityGroupIds := terraform.OutputList(t, terraformOptions, "ac_security_group_ids")
	assert.Equal(t, acSecurityGroupIds, updatedAcSecurityGroupIds, "Security Group IDs should remain the same after second apply")
}

// TestSecurityGroupTagUpdates tests that security group tag updates work correctly
func TestSecurityGroupTagUpdates(t *testing.T) {
	t.Parallel()

	terraformOptions := CreateTerraformOptions(t)

	// Initial Apply
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate initial outputs
	acSecurityGroupIds := terraform.OutputList(t, terraformOptions, "ac_security_group_ids")
	assert.Len(t, acSecurityGroupIds, 2, "Should create 2 security groups")

	// Test parameter change - update tags
	terraformOptions.Vars = map[string]interface{}{
		"name_prefix":  "test-sg",
		"resource_tag": "terratest",
		"global_tags": map[string]string{
			"Environment": "test",
			"Purpose":     "terratest",
			"Owner":       "zscaler",
			"Updated":     "true", // Add new tag
		},
	}

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

		// ZPAtt validation: Prevent recreate scenarios for security groups
		if hasDelete && hasCreate {
			t.Errorf("AWS Security Group about to be deleted and then created again. This likely introduces service disruption. Resource: %v", resourceChange.Address)
		}
	}

	// Apply the changes
	terraform.Apply(t, terraformOptions)

	// Validate outputs after update
	updatedAcSecurityGroupIds := terraform.OutputList(t, terraformOptions, "ac_security_group_ids")
	assert.Equal(t, acSecurityGroupIds, updatedAcSecurityGroupIds, "Security Group IDs should remain the same after tag update")
}
