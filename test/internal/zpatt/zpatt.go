// ZPA-specific utility that runs terratest for ZPA modules with standardized behavior
package zpatt

import (
	"regexp"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	tfjson "github.com/hashicorp/terraform-json"
)

// CheckFunc is a function that can be run on an applied Terraform test-case as given by t.
// The terraformOptions should be the same which were used to apply t.
// The function should either exit cleanly, or invoke t.Errorf() which fails the entire test-case in a usual way.
type CheckFunc func(t *testing.T, terraformOptions *terraform.Options)

// ZPATest runs the Terratest with ZPA-specific settings. The outputs of the Terraform need to pass both
// checkFunc and the standard CheckZPAOutputsCorrect function.
func ZPATest(t *testing.T, terraformOptions *terraform.Options, checkFunc CheckFunc) *terraform.Options {
	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	if terraformOptions == nil {
		terraformOptions = terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			// The path to where our Terraform code is located
			TerraformDir: ".",

			// Variables to pass to our Terraform code using -var options
			Vars: map[string]interface{}{
				"test_mode": "initial",
			},
		})
	}

	if checkFunc == nil {
		checkFunc = func(t *testing.T, terraformOptions *terraform.Options) { /* noop */ }
	}

	// Schedule `terraform destroy` at the end of the test, to clean up the created resources.
	destroyFunc := func() {
		logger.Log(t, "#################### End of logs for the Apply. Cleaning up now. ####################")
		terraform.Destroy(t, terraformOptions)
	}
	defer destroyFunc()

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)
	CheckZPAOutputsCorrect(t, terraformOptions)
	checkFunc(t, terraformOptions)

	// Run `terraform init` and `terraform apply` again, with modified input.
	// We will see whether the ZPA resources can be modified after their initial creation.
	terraformOptions.Vars["test_mode"] = "modified"

	// Plan file is required later by InitAndPlanAndShowWithStruct function.
	prev := terraformOptions.PlanFilePath
	defer func() { terraformOptions.PlanFilePath = prev }()
	terraformOptions.PlanFilePath = "tmp.plan"

	ps := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	terraformOptions.PlanFilePath = prev

	for _, v := range ps.ResourceChangesMap {
		checkZPAResourceChange(t, v)
	}

	// Don't waste time for a lengthy apply if checks failed so far.
	if t.Failed() {
		return terraformOptions
	}

	terraform.InitAndApply(t, terraformOptions)
	CheckZPAOutputsCorrect(t, terraformOptions)
	checkFunc(t, terraformOptions)

	return terraformOptions
}

func checkZPAResourceChange(t *testing.T, v *tfjson.ResourceChange) {
	hasDel, hasCre := false, false

	for _, action := range v.Change.Actions {
		if action == tfjson.ActionDelete {
			hasDel = true
		}
		if action == tfjson.ActionCreate {
			hasCre = true
		}
	}

	// ZPA resources should not be recreated unnecessarily
	if hasDel && hasCre {
		t.Errorf(`ZPA Resource about to be deleted and then created again after changing test_mode.
This likely introduces service disruption. ZPA resources should be updated in-place when possible.
Resource: %v`, v.Address)
	}
}

// CheckZPAOutputsCorrect verifies ZPA-specific output validations
func CheckZPAOutputsCorrect(t *testing.T, terraformOptions *terraform.Options) {
	// Check that no outputs return "false" (indicating failures)
	notwant := "false"

	for output := range terraform.OutputAll(t, terraformOptions) {
		// Run `terraform output` and check the results.
		got := terraform.Output(t, terraformOptions, output)
		got = strings.ToLower(got)

		if got == notwant {
			t.Errorf("ZPA output %q returned false, indicating a failure:\ngot:  %q\nwant anything but %q\n", output, got, notwant)
		}
	}

	// ZPA-specific validations
	validateZPAOutputs(t, terraformOptions)
}

// validateZPAOutputs performs ZPA-specific output validations
func validateZPAOutputs(t *testing.T, terraformOptions *terraform.Options) {
	// Validate App Connector Group ID format
	if appConnectorGroupId := terraform.Output(t, terraformOptions, "app_connector_group_id"); appConnectorGroupId != "" {
		if !isValidZPAID(appConnectorGroupId) {
			t.Errorf("Invalid ZPA App Connector Group ID format: %s", appConnectorGroupId)
		}
	}

	// Validate Provisioning Key format
	if provisioningKey := terraform.Output(t, terraformOptions, "provisioning_key"); provisioningKey != "" {
		if !isValidProvisioningKey(provisioningKey) {
			t.Errorf("Invalid ZPA Provisioning Key format: %s", provisioningKey)
		}
	}
}

// isValidZPAID validates ZPA ID format (typically UUID-like)
func isValidZPAID(id string) bool {
	// ZPA IDs are typically UUIDs or similar format
	uuidRegex := regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)
	return uuidRegex.MatchString(strings.ToLower(id))
}

// isValidProvisioningKey validates ZPA Provisioning Key format
func isValidProvisioningKey(key string) bool {
	// ZPA Provisioning Keys are typically base64-like strings
	// They should be non-empty and contain valid characters
	if len(key) < 10 {
		return false
	}

	// Check for valid base64-like characters
	validChars := regexp.MustCompile(`^[A-Za-z0-9+/=]+$`)
	return validChars.MatchString(key)
}

// TestZPAModuleWithChanges tests a ZPA module with parameter changes
func TestZPAModuleWithChanges(t *testing.T, terraformOptions *terraform.Options, changes map[string]interface{}) {
	// Apply initial configuration
	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	// Apply changes
	for key, value := range changes {
		terraformOptions.Vars[key] = value
	}

	// Plan and validate changes
	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Validate that changes are updates, not recreates
	for _, resourceChange := range plan.ResourceChangesMap {
		checkZPAResourceChange(t, resourceChange)
	}

	// Apply changes
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs after changes
	CheckZPAOutputsCorrect(t, terraformOptions)
}
