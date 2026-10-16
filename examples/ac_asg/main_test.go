package ac_asg

import (
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
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

// TestPlanInstanceRefresh checks that instance refresh is off by default, rolls
// the group when enabled with provisioning key onboarding, and is refused with
// OAuth2 onboarding, where replaced instances would not be enrolled.
func TestPlanInstanceRefresh(t *testing.T) {
	t.Run("disabled", func(t *testing.T) {
		plan := testhelpers.Plan(t, CreateTerraformOptions(t))
		testhelpers.AssertInstanceRefresh(t, plan, false)
	})

	t.Run("provisioning_key", func(t *testing.T) {
		opts := CreateTerraformOptions(t)
		opts.Vars["onboarding_method"] = "provisioning_key"
		opts.Vars["instance_refresh_enabled"] = true
		plan := testhelpers.Plan(t, opts)
		testhelpers.AssertInstanceRefresh(t, plan, true)
	})

	t.Run("oauth_rejected", func(t *testing.T) {
		opts := CreateTerraformOptions(t)
		opts.Vars["instance_refresh_enabled"] = true
		err := testhelpers.PlanE(t, opts)
		require.Error(t, err)
		require.Contains(t, err.Error(), "instance_refresh_enabled requires provisioning key onboarding")
	})
}

func TestApply(t *testing.T) {
	testskeleton.DeployInfraCheckOutputs(t, CreateTerraformOptions(t),
		[]testskeleton.AssertExpression{})
}

func TestIdempotence(t *testing.T) {
	testskeleton.DeployInfraCheckOutputsVerifyChanges(t, CreateTerraformOptions(t),
		[]testskeleton.AssertExpression{})
}
