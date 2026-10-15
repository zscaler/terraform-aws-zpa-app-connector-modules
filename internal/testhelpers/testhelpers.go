// Package testhelpers holds plan-level assertions shared by the example
// Terratest suites. The test skeleton only asserts Terraform outputs, which do
// not expose AMI or bootstrap script selection, so these helpers read the plan
// instead.
package testhelpers

import (
	"encoding/base64"
	"path/filepath"
	"strings"
	"testing"

	tfjson "github.com/hashicorp/terraform-json"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// Target is the App Connector resource that receives the AMI and bootstrap
// script, with the names of the attributes that hold them.
type Target struct {
	Address      string
	AMIAttr      string
	UserDataAttr string
}

var (
	AppConnectorVM = Target{
		Address:      "module.ac_vm.aws_instance.ac_vm[0]",
		AMIAttr:      "ami",
		UserDataAttr: "user_data_base64",
	}
	AppConnectorLaunchTemplate = Target{
		Address:      "module.ac_asg.aws_launch_template.ac_launch_template[0]",
		AMIAttr:      "image_id",
		UserDataAttr: "user_data",
	}
)

// AppConnectorASG is the Auto Scaling group created by the ASG examples.
const AppConnectorASG = "module.ac_asg.aws_autoscaling_group.ac_asg"

const (
	zscalerAMILookup   = "data.aws_ami.appconnector[0]"
	rhel9AMILookup     = "data.aws_ami.rhel_9_latest[0]"
	zscalerProductCode = "by1wc5269g0048ix2nqvr0362"
	redHatOwnerID      = "309956199498"
	rhel9RepoURL       = "https://yum.private.zscaler.com/yum/el9"
)

// Plan runs init and plan for the options and returns the parsed plan.
func Plan(t *testing.T, opts *terraform.Options) *terraform.PlanStruct {
	t.Helper()
	opts.PlanFilePath = filepath.Join(t.TempDir(), "test.plan")
	return terraform.InitAndPlanAndShowWithStruct(t, opts)
}

// PlannedAttributes returns the planned attribute values of a resource.
func PlannedAttributes(t *testing.T, plan *terraform.PlanStruct, address string) map[string]interface{} {
	t.Helper()
	resource, ok := plan.ResourcePlannedValuesMap[address]
	require.Truef(t, ok, "resource %s is not in the plan", address)
	return resource.AttributeValues
}

// dataSource returns a data source read during planning. Terraform records
// those in the plan's prior state rather than in its planned values.
func dataSource(plan *terraform.PlanStruct, address string) *tfjson.StateResource {
	if plan.RawPlan.PriorState == nil || plan.RawPlan.PriorState.Values == nil {
		return nil
	}
	return findResource(plan.RawPlan.PriorState.Values.RootModule, address)
}

func findResource(module *tfjson.StateModule, address string) *tfjson.StateResource {
	if module == nil {
		return nil
	}
	for _, r := range module.Resources {
		if r.Address == address {
			return r
		}
	}
	for _, child := range module.ChildModules {
		if r := findResource(child, address); r != nil {
			return r
		}
	}
	return nil
}

// AssertImageSelection checks that the target uses the AMI and bootstrap
// script matching use_zscaler_ami: the latest Zscaler Marketplace AMI with the
// Zscaler script, or the latest RHEL 9 AMI with the script that installs the
// connector from the Zscaler el9 yum repository.
//
// The bootstrap script is only known at plan time when the SSM parameter name
// is, so callers must set byo_ssm_parameter_name.
func AssertImageSelection(t *testing.T, plan *terraform.PlanStruct, target Target, useZscalerAMI bool) {
	t.Helper()
	want, other := rhel9AMILookup, zscalerAMILookup
	if useZscalerAMI {
		want, other = zscalerAMILookup, rhel9AMILookup
	}

	ami := dataSource(plan, want)
	require.NotNilf(t, ami, "AMI lookup %s was not read during plan", want)
	require.Nilf(t, dataSource(plan, other), "AMI lookup %s should not run", other)

	if useZscalerAMI {
		require.Containsf(t, productCodes(ami.AttributeValues), zscalerProductCode,
			"AMI %v is not the Zscaler App Connector Marketplace AMI", ami.AttributeValues["name"])
	} else {
		require.Equal(t, redHatOwnerID, ami.AttributeValues["owner_id"], "RHEL AMI owner")
		require.Truef(t, strings.HasPrefix(ami.AttributeValues["name"].(string), "RHEL-9."),
			"AMI %v is not a RHEL 9 image", ami.AttributeValues["name"])
		require.Equal(t, "x86_64", ami.AttributeValues["architecture"], "RHEL AMI architecture")
	}

	attrs := PlannedAttributes(t, plan, target.Address)
	require.Equal(t, ami.AttributeValues["id"], attrs[target.AMIAttr], "AMI used by %s", target.Address)

	installsFromRepo := strings.Contains(userData(t, attrs, target), rhel9RepoURL)
	if useZscalerAMI {
		require.Falsef(t, installsFromRepo, "Zscaler AMI must not run the RHEL bootstrap script (%s)", rhel9RepoURL)
	} else {
		require.Truef(t, installsFromRepo, "RHEL AMI must run the RHEL bootstrap script (%s)", rhel9RepoURL)
	}
}

// AssertInstanceRefresh checks the Auto Scaling group's instance refresh. When
// enabled, the group must reference the launch template's latest version
// number, which is unknown until apply; "$Latest" never starts a refresh.
func AssertInstanceRefresh(t *testing.T, plan *terraform.PlanStruct, enabled bool) {
	t.Helper()
	attrs := PlannedAttributes(t, plan, AppConnectorASG)
	refresh, _ := attrs["instance_refresh"].([]interface{})
	if !enabled {
		require.Empty(t, refresh, "instance_refresh block")
		templates := attrs["launch_template"].([]interface{})
		require.Equal(t, "$Latest", templates[0].(map[string]interface{})["version"], "launch template version")
		return
	}

	require.Len(t, refresh, 1, "instance_refresh block")
	block := refresh[0].(map[string]interface{})
	require.Equal(t, "Rolling", block["strategy"], "instance refresh strategy")
	prefs := block["preferences"].([]interface{})[0].(map[string]interface{})
	require.EqualValues(t, 90, prefs["min_healthy_percentage"], "min_healthy_percentage")
	require.Equal(t, true, prefs["skip_matching"], "skip_matching")

	change, ok := plan.ResourceChangesMap[AppConnectorASG]
	require.Truef(t, ok, "resource %s has no planned change", AppConnectorASG)
	unknown, _ := change.Change.AfterUnknown.(map[string]interface{})
	templates, _ := unknown["launch_template"].([]interface{})
	require.NotEmpty(t, templates, "launch_template should reference the latest version number")
	require.Equal(t, true, templates[0].(map[string]interface{})["version"],
		"launch template version should be the latest version number, known after apply")
}

// PlanE runs init and plan and returns the error instead of failing the test.
func PlanE(t *testing.T, opts *terraform.Options) error {
	t.Helper()
	_, err := terraform.InitAndPlanE(t, opts)
	return err
}

func productCodes(attrs map[string]interface{}) []string {
	var codes []string
	raw, _ := attrs["product_codes"].([]interface{})
	for _, c := range raw {
		if m, ok := c.(map[string]interface{}); ok {
			if id, ok := m["product_code_id"].(string); ok {
				codes = append(codes, id)
			}
		}
	}
	return codes
}

func userData(t *testing.T, attrs map[string]interface{}, target Target) string {
	t.Helper()
	encoded, ok := attrs[target.UserDataAttr].(string)
	require.Truef(t, ok, "%s of %s is unknown at plan time; set byo_ssm_parameter_name", target.UserDataAttr, target.Address)
	decoded, err := base64.StdEncoding.DecodeString(encoded)
	require.NoError(t, err, "decode %s", target.UserDataAttr)
	return string(decoded)
}
