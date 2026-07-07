package base_ac_asg

import (
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/zscaler/terraform-modules-zscaler-tests-skeleton/pkg/testskeleton"
)

func CreateTerraformOptions(t *testing.T) *terraform.Options {
	varsInfo, err := testskeleton.GenerateTerraformVarsInfo("aws")
	if err != nil {
		log.Fatalf("Error generating terraform vars info: %v", err)
	}

	region := os.Getenv("AWS_REGION")
	if region == "" {
		region = "us-west-2"
	}

	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		VarFiles:     []string{"terraform.tfvars"},
		Vars: map[string]interface{}{
			"name_prefix": varsInfo.NamePrefix,
			"aws_region":  region,
		},
		Logger:               logger.Default,
		Lock:                 true,
		Upgrade:              true,
		SetVarsAfterVarFiles: true,
	})
}

func TestValidate(t *testing.T) {
	testskeleton.ValidateCode(t, nil)
}

func TestPlan(t *testing.T) {
	testskeleton.PlanInfraCheckErrors(t, CreateTerraformOptions(t),
		[]testskeleton.AssertExpression{}, "No errors are expected")
}

// skipASGOAuthDeploy disables the deploy-based tests for this example in CI.
// The OAuth2 onboarding flow reads data.external.asg_oauth_tokens, which polls
// SSM for a user code from every desired ASG instance and intentionally blocks
// until all codes are collected. ASG instances do not reliably publish their
// /etc/issue codes within the CI window, so the read runs until the action
// times out. Re-enable once ASG user-code publication is deterministic in CI.
const skipASGOAuthDeploy = "Disabled in CI: OAuth2 ASG onboarding polls SSM (data.external.asg_oauth_tokens) for user codes that ASG instances do not publish in time, causing the action to time out."

func TestApply(t *testing.T) {
	t.Skip(skipASGOAuthDeploy)
	testskeleton.DeployInfraCheckOutputs(t, CreateTerraformOptions(t),
		[]testskeleton.AssertExpression{})
}

func TestIdempotence(t *testing.T) {
	t.Skip(skipASGOAuthDeploy)
	testskeleton.DeployInfraCheckOutputsVerifyChanges(t, CreateTerraformOptions(t),
		[]testskeleton.AssertExpression{})
}
