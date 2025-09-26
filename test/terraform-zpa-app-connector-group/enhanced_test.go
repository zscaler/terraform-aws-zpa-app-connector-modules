package terraform_zpa_app_connector_group

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/zscaler/terraform-aws-zpa-app-connector-modules/test/internal/zpatt"
)

func CreateEnhancedTerraformOptions(t *testing.T) *terraform.Options {
	// define options for Terraform
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"test_mode":                                    "initial",
			"app_connector_group_name":                     "test-app-connector-group",
			"app_connector_group_description":              "Test App Connector Group",
			"app_connector_group_enabled":                  true,
			"app_connector_group_country_code":             "US",
			"app_connector_group_latitude":                 "37.3382082",
			"app_connector_group_longitude":                "-121.8863286",
			"app_connector_group_location":                 "San Jose, CA, USA",
			"app_connector_group_upgrade_day":              "SUNDAY",
			"app_connector_group_upgrade_time_in_secs":     "66600",
			"app_connector_group_override_version_profile": true,
			"app_connector_group_version_profile_id":       "0",
			"app_connector_group_dns_query_type":           "IPV4_IPV6",
		},
		Logger:               logger.Default,
		Lock:                 true,
		Upgrade:              true,
		SetVarsAfterVarFiles: true,
	})

	return terraformOptions
}

func TestZPAEnhancedValidation(t *testing.T) {
	terraformOptions := CreateEnhancedTerraformOptions(t)

	// Custom check function for ZPA-specific validations
	checkFunc := func(t *testing.T, terraformOptions *terraform.Options) {
		// Verify App Connector Group ID is valid
		appConnectorGroupId := terraform.Output(t, terraformOptions, "app_connector_group_id")
		assert.NotEmpty(t, appConnectorGroupId, "App Connector Group ID should not be empty")

		// Additional ZPA-specific validations can be added here
		t.Logf("App Connector Group ID: %s", appConnectorGroupId)
	}

	// Run enhanced ZPA test
	zpatt.ZPATest(t, terraformOptions, checkFunc)
}

func TestZPALocationChange(t *testing.T) {
	terraformOptions := CreateEnhancedTerraformOptions(t)

	// Test location change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_latitude":  "40.7128", // New York
		"app_connector_group_longitude": "-74.0060",
		"app_connector_group_location":  "New York, NY, USA",
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}

func TestZPAVersionProfileChange(t *testing.T) {
	terraformOptions := CreateEnhancedTerraformOptions(t)

	// Test version profile change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_version_profile_id": "2", // Change from "0" to "2"
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}

func TestZPADescriptionChange(t *testing.T) {
	terraformOptions := CreateEnhancedTerraformOptions(t)

	// Test description change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_description": "Updated Test App Connector Group",
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}

func TestZPADNSQueryTypeChange(t *testing.T) {
	terraformOptions := CreateEnhancedTerraformOptions(t)

	// Test DNS query type change (should update, not recreate)
	changes := map[string]interface{}{
		"app_connector_group_dns_query_type": "IPV4_ONLY", // Change from "IPV4_IPV6"
	}

	zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}
