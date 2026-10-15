package ac_asg

import (
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/zscaler/terraform-aws-zpa-app-connector-modules/internal/testhelpers"
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

// TestPlanImageSelection checks that use_zscaler_ami selects both the AMI and
// the matching bootstrap script. byo_ssm_parameter_name keeps the script known
// at plan time; the default parameter name has a random suffix.
func TestPlanImageSelection(t *testing.T) {
	for _, tc := range []struct {
		name          string
		useZscalerAMI bool
	}{
		{name: "zscaler", useZscalerAMI: true},
		{name: "rhel9", useZscalerAMI: false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			opts := CreateTerraformOptions(t)
			opts.Vars["use_zscaler_ami"] = tc.useZscalerAMI
			opts.Vars["byo_ssm_parameter_name"] = "/zpa/terratest"
			plan := testhelpers.Plan(t, opts)
			testhelpers.AssertImageSelection(t, plan, testhelpers.AppConnectorLaunchTemplate, tc.useZscalerAMI)
		})
	}
}

func TestApply(t *testing.T) {
	testskeleton.DeployInfraCheckOutputs(t, CreateTerraformOptions(t),
		[]testskeleton.AssertExpression{})
}

func TestIdempotence(t *testing.T) {
	testskeleton.DeployInfraCheckOutputsVerifyChanges(t, CreateTerraformOptions(t),
		[]testskeleton.AssertExpression{})
}
