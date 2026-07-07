![GitHub release (latest by date)](https://img.shields.io/github/v/release/zscaler/terraform-aws-zpa-app-connector-modules?style=flat-square)
![GitHub](https://img.shields.io/github/license/zscaler/terraform-aws-zpa-app-connector-modules?style=flat-square)
![GitHub pull requests](https://img.shields.io/github/issues-pr/zscaler/terraform-aws-zpa-app-connector-modules?style=flat-square)
![Terraform registry downloads total](https://img.shields.io/badge/dynamic/json?color=green&label=downloads%20total&query=data.attributes.total&url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fmodules%2Fzscaler%2Fzpa-app-connector-modules%2Faws%2Fdownloads%2Fsummary&style=flat-square)
![Terraform registry download month](https://img.shields.io/badge/dynamic/json?color=green&label=downloads%20this%20month&query=data.attributes.month&url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fmodules%2Fzscaler%2Fzpa-app-connector-modules%2Faws%2Fdownloads%2Fsummary&style=flat-square)
[![Zscaler Community](https://img.shields.io/badge/zscaler-community-blue)](https://community.zscaler.com/)

# Zscaler App Connector AWS Terraform Modules

## Support Disclaimer

-> **Disclaimer:** Please refer to our [General Support Statement](docs/guides/support.md) before proceeding with the use of this provider.

## BREAKING CHANGES - OAuth2 Authentication

~> **BREAKING CHANGE** As of version 2.0.0 of this module, the **default** App Connector enrollment method changed from the **Provisioning Key** method to the new **OAuth2 User Code** method. The provisioning key method is **not deprecated or removed** — it remains fully supported as the secondary onboarding method. Because the default behavior changed, upgrading existing deployments that relied on the previous provisioning-key default requires an explicit opt-in (see [Upgrade Path](#upgrade-path)).

### Onboarding Methods

Both methods are selectable per deployment via the `onboarding_method` variable:

- **`oauth` (default):** Enrolls connectors via OAuth2 user codes. Each VM publishes its user code (from `/etc/issue`) to AWS SSM Parameter Store using its instance role; Terraform reads the codes back and creates the App Connector Group with the collected `user_codes`.
- **`provisioning_key` (secondary):** The classic flow. A provisioning key is created (or supplied via `byo_provisioning_key`) and injected into VM `user_data`, and App Connectors auto-enroll on boot.

To use the provisioning key method, set `onboarding_method = "provisioning_key"` (or `byo_provisioning_key = true`) in your `terraform.tfvars`.

### What Changed

**OAuth2 flow (new default):**
1. Deploy App Connector VMs
2. Each VM publishes its OAuth2 user code (from `/etc/issue`) to SSM Parameter Store
3. Terraform reads the user codes back from SSM
4. Create the App Connector Group with the collected `user_codes`; connectors enroll via the OAuth2 verification API

**Provisioning key flow (still supported):**
1. Create App Connector Group and Provisioning Key
2. Deploy VMs with the provisioning key injected via `user_data`
3. App Connectors auto-enroll using the provisioning key

### Migration Impact

- **Default method changed:** New deployments default to OAuth2. Set `onboarding_method = "provisioning_key"` to keep the previous behavior.
- **Provisioning key retained:** The `terraform-zpa-provisioning-key` module and all provisioning-key variables (`byo_provisioning_key`, `byo_provisioning_key_name`, `provisioning_key_enabled`, `provisioning_key_association_type`, `provisioning_key_max_usage`) are still present.
- **New variables:** Added `onboarding_method` (default: `oauth`) and `user_codes` (list of OAuth2 user codes) on the App Connector Group module.
- **Deployment order (OAuth2 only):** With OAuth2, the App Connector Group is created **after** VM deployment so the user codes can be collected first. The provisioning-key flow keeps the original order.
- **Version profile defaults:** `app_connector_group_override_version_profile` now defaults to `false` and `app_connector_group_version_profile_id` defaults to `""` (the module resolves the "Default" profile automatically). Existing configs relying on the old defaults may show a plan diff on upgrade.

### Implementation Notes

For the OAuth2 flow, user codes are relayed through **AWS SSM Parameter Store** rather than SSH:
- Each VM writes its user code (from `/etc/issue`) to a per-instance SSM parameter using its instance role
- Terraform reads the parameters back and passes the codes to the App Connector Group for enrollment

**For base_ac / ac deployments:** VMs publish to fixed, per-instance SSM parameters that Terraform reads directly.
**For ASG deployments (`base_ac_asg` / `ac_asg`):** an `external` data source polls SSM for a user code from every desired ASG instance before enrollment.

### Upgrade Path

Existing deployments continue to be managed by version 2.0.0+ — the provisioning key method is still supported. Choose the path that matches your setup:

- **Stay on provisioning keys:** Set `onboarding_method = "provisioning_key"` (or `byo_provisioning_key = true`) so the default change to OAuth2 does not affect your deployment, then upgrade the module version.
- **Adopt OAuth2:** Leave `onboarding_method` at its default (`oauth`). Note that switching enrollment methods on an existing App Connector Group typically requires re-deploying the connectors.

**Note:** You can switch between methods per deployment by changing `onboarding_method`; it is not a one-way migration at the module level.

## Description
This repository contains various modules and deployment configurations that can be used to deploy Zscaler App Connector appliances to securely connect to workloads within Amazon Web Services (AWS) via the Zscaler Zero Trust Exchange. The examples directory contains complete automation scripts for both greenfield/POV and brownfield/production use.

These deployment templates are intended to be fully functional and self service for both greenfield/pov as well as production use. All modules may also be utilized as design recommendation based on Zscaler's Official [Zero Trust Access to Private Apps in AWS with ZPA](https://www.zscaler.com/resources/reference-architecture/zero-trust-with-zpa.pdf).

~> **IMPORTANT** As of version 1.4.0 of this module, all App Connectors are deployed using the new [Red Hat Enterprise Linux 9](https://help.zscaler.com/zpa/app-connector-red-hat-enterprise-linux-9-migration)

## Prerequisites

Our Deployment scripts are leveraging Terraform v1.1.9 that includes full binary and provider support for MacOS M1 chips, but any Terraform version 0.13.7 should be generally supported.

- provider registry.terraform.io/hashicorp/aws v5.58.x
- provider registry.terraform.io/hashicorp/random v3.6.x
- provider registry.terraform.io/hashicorp/local v2.5.x
- provider registry.terraform.io/hashicorp/null v3.2.x
- provider registry.terraform.io/providers/hashicorp/tls v4.0.x
- provider registry.terraform.io/providers/zscaler/zpa v3.31.x

### AWS requirements
1. A valid AWS account
2. AWS ACCESS KEY ID
3. AWS SECRET ACCESS KEY
4. AWS Region (E.g. us-west-2)
5. Subscribe and accept terms of using Amazon Linux 2 AMI (for base deployments with workloads + bastion) at [this link](https://aws.amazon.com/marketplace/pp/prodview-zc4x2k7vt6rpu)
6. Subscribe and accept terms of using Zscaler App Connector image at [this link](https://aws.amazon.com/marketplace/pp/prodview-epy3md7fcvk4g)

### Zscaler requirements
This module leverages the Zscaler Private Access [ZPA Terraform Provider](https://registry.terraform.io/providers/zscaler/zpa/latest/docs) for the automated onboarding process. Before proceeding make sure you have the following pre-requistes ready.

## Legacy ZPA API Authentication Framework

1. A valid Zscaler Private Access subscription and portal access
2. Zscaler ZPA API Keys. Details on how to find and generate ZPA API keys can be located [here](https://registry.terraform.io/providers/zscaler/zpa/latest/docs#legacy-api-framework)
- `zpa_client_id`
- `zpa_client_secret`
- `zpa_customer_id`
- `zpa_cloud` - This authentication parameter is optional and only required if authenticating to a non-production cloud i.e `BETA`, `GOV`, `GOVUS`, `ZPATWO`
- `use_legacy_client` - This parameter MUST be set to `true` if your tenant is NOT migrated to Zidentity.

```hcl
provider "zpa" {
  zpa_client_id            = "zpa_client_id" # pragma: allowlist secret
  zpa_client_secret        = "zpa_client_secret" # pragma: allowlist secret
  zpa_customer_id          = "zpa_client_secret" # pragma: allowlist secret
  zpa_cloud                = "zpa_cloud" # pragma: allowlist secret
  use_legacy_client        = "true" # pragma: allowlist secret
}
```

3. **OAuth2 Authentication**: This module uses OAuth2 user codes for App Connector enrollment. User codes are automatically generated at `/etc/issue` on deployed VMs and retrieved via SSH.

See: [Zscaler App Connector AWS Deployment Guide](https://help.zscaler.com/zpa/connector-deployment-guide-amazon-web-services) for additional prerequisite provisioning steps.

## ZPA OneAPI Authentication Framework (OneAPI)

1. A valid Zscaler Private Access subscription and portal access
2. Zscaler tenant MUST be migrated to Zidentity platform.
2. Details on how to authenticate to ZPA via Zidentity/OneAPI are located here [here](https://registry.terraform.io/providers/zscaler/zpa/latest/docs#authentication---oneapi-new-framework)
- `client_id`
- `client_secret`
- `zpa_customer_id`
- `vanity_domain`
- `zscaler_cloud` - This authentication parameter is optional and only required if authenticating to a non-production cloud i.e `beta`

```hcl
provider "zpa" {
  client_id = "client_id" # pragma: allowlist secret
  client_secret = "client_secret" # pragma: allowlist secret
  zpa_customer_id = "client_secret" # pragma: allowlist secret
  vanity_domain = "vanity_domain" # pragma: allowlist secret
  zscaler_cloud = "zscaler_cloud" # pragma: allowlist secret
}
```
3. **OAuth2 Authentication**: This module uses OAuth2 user codes for App Connector enrollment. User codes are automatically generated at `/etc/issue` on deployed VMs and retrieved via SSH.

See: [Zscaler App Connector AWS Deployment Guide](https://help.zscaler.com/zpa/connector-deployment-guide-amazon-web-services) for additional prerequisite provisioning steps.


## How to deploy
Provisioning templates are available for customer use/reference to successfully deploy fully operational App Connector appliances once the prerequisites have been completed. Please follow the instructions located in [examples](examples/README.md).

## Format

This repository follows the [Hashicorp Standard Modules Structure](https://www.terraform.io/registry/modules/publish):

* `modules` - All module resources utilized by and customized specifically for App Connector deployments. The intent is these modules are resusable and functional for any deployment type referencing for both production or lab/testing purposes.
* `examples` - Zscaler provides fully functional deployment templates utilizing a combination of some or all of the modules published. These can utilized in there entirety or as reference templates for more advanced customers or custom deployments. For novice Terraform users, we also provide a bash script (zsac) that can be run from any Linux/Mac OS or CSP Cloud Shell that walks through all provisioning requirements as well as downloading/running an isolated teraform process. This allows App Connector deployments from any supported client without needing to even have Terraform installed or know how the language/syntax for running it.

## Versioning

These modules follow recommended release tagging in [Semantic Versioning](http://semver.org/). You can find each new release,
along with the changelog, on the GitHub [Releases](https://github.com/zscaler/terraform-aws-zpa-app-connector-modules/releases) page.

# License and Copyright

Copyright (c) 2022 Zscaler, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
