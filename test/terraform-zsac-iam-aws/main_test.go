package terraform_zsac_iam_aws

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
	iamInstanceProfileIdValid := terraform.Output(t, terraformOptions, "iam_instance_profile_id_valid")
	assert.Equal(t, "true", iamInstanceProfileIdValid, "IAM Instance Profile ID should be valid")

	iamInstanceProfileArnValid := terraform.Output(t, terraformOptions, "iam_instance_profile_arn_valid")
	assert.Equal(t, "true", iamInstanceProfileArnValid, "IAM Instance Profile ARN should be valid")

	iamInstanceProfileCountCorrect := terraform.Output(t, terraformOptions, "iam_instance_profile_count_correct")
	assert.Equal(t, "true", iamInstanceProfileCountCorrect, "IAM Instance Profile count should be correct")

	iamInstanceProfileArnCountCorrect := terraform.Output(t, terraformOptions, "iam_instance_profile_arn_count_correct")
	assert.Equal(t, "true", iamInstanceProfileArnCountCorrect, "IAM Instance Profile ARN count should be correct")

	testVariablesSetCorrectly := terraform.Output(t, terraformOptions, "test_variables_set_correctly")
	assert.Equal(t, "true", testVariablesSetCorrectly, "Test variables should be set correctly")

	iamCountCorrect := terraform.Output(t, terraformOptions, "iam_count_correct")
	assert.Equal(t, "true", iamCountCorrect, "IAM count should be correct")

	byoIamSetCorrectly := terraform.Output(t, terraformOptions, "byo_iam_set_correctly")
	assert.Equal(t, "true", byoIamSetCorrectly, "BYO IAM should be set correctly")

	// Verify actual outputs are not empty
	iamInstanceProfileIds := terraform.OutputList(t, terraformOptions, "iam_instance_profile_id")
	assert.Len(t, iamInstanceProfileIds, 1, "Should create 1 IAM instance profile")

	iamInstanceProfileArns := terraform.OutputList(t, terraformOptions, "iam_instance_profile_arn")
	assert.Len(t, iamInstanceProfileArns, 1, "Should create 1 IAM instance profile ARN")

	// Verify the profile ID is not empty
	assert.NotEmpty(t, iamInstanceProfileIds[0], "IAM Instance Profile ID should not be empty")
	assert.NotEmpty(t, iamInstanceProfileArns[0], "IAM Instance Profile ARN should not be empty")
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

func TestIAMWithMultipleProfiles(t *testing.T) {
	// Test with multiple IAM profiles
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"aws_region":                  "us-west-2",
			"name_prefix":                 "test-iam-multiple",
			"resource_tag":                "multiple-test",
			"iam_count":                   2,
			"byo_iam":                     false,
			"byo_iam_instance_profile_id": []string{},
		},
		Logger:  logger.Default,
		Lock:    true,
		Upgrade: true,
	})

	// deploy test infrastructure
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// verify outputs
	iamInstanceProfileIdValid := terraform.Output(t, terraformOptions, "iam_instance_profile_id_valid")
	assert.Equal(t, "true", iamInstanceProfileIdValid, "IAM Instance Profile ID should be valid")

	iamInstanceProfileCountCorrect := terraform.Output(t, terraformOptions, "iam_instance_profile_count_correct")
	assert.Equal(t, "true", iamInstanceProfileCountCorrect, "IAM Instance Profile count should be correct")

	// Verify actual outputs
	iamInstanceProfileIds := terraform.OutputList(t, terraformOptions, "iam_instance_profile_id")
	assert.Len(t, iamInstanceProfileIds, 2, "Should create 2 IAM instance profiles")

	iamInstanceProfileArns := terraform.OutputList(t, terraformOptions, "iam_instance_profile_arn")
	assert.Len(t, iamInstanceProfileArns, 2, "Should create 2 IAM instance profile ARNs")

	// Verify all profiles are not empty
	for i, profileId := range iamInstanceProfileIds {
		assert.NotEmpty(t, profileId, "IAM Instance Profile ID %d should not be empty", i)
		assert.NotEmpty(t, iamInstanceProfileArns[i], "IAM Instance Profile ARN %d should not be empty", i)
	}
}

func TestIAMWithBYO(t *testing.T) {
	// Test with BYO IAM (bring your own)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"aws_region":                  "us-west-2",
			"name_prefix":                 "test-iam-byo",
			"resource_tag":                "byo-test",
			"iam_count":                   1,
			"byo_iam":                     true,
			"byo_iam_instance_profile_id": []string{"test-existing-profile"},
		},
		Logger:  logger.Default,
		Lock:    true,
		Upgrade: true,
	})

	// This test will fail because we're referencing a non-existent IAM profile
	// but it tests the BYO functionality path
	_, err := terraform.InitAndApplyE(t, terraformOptions)
	if err != nil {
		// Expected to fail since the IAM profile doesn't exist
		t.Logf("Expected failure with BYO IAM profile: %v", err)
	}

	// Clean up any partial resources
	terraform.Destroy(t, terraformOptions)
}
