# ZPA App Connector Modules Tests

This directory contains comprehensive tests for the ZPA App Connector Terraform modules using gruntwork-io/terratest.

## Prerequisites

1. **Go 1.20+** installed
2. **Terraform** installed
3. **ZPA API credentials** configured as environment variables:
   - `ZPA_CLIENT_ID`
   - `ZPA_CLIENT_SECRET` 
   - `ZPA_CUSTOMER_ID`
   - `ZPA_CLOUD`

## Test Structure

```
test/
├── terraform-zpa-app-connector-group/
│   ├── main_test.go
│   ├── main.tf
│   └── variables.tf
├── terraform-zpa-provisioning-key/
│   ├── main_test.go
│   ├── main.tf
│   └── variables.tf
└── README.md
```

## Running Tests

### Run all tests:
```bash
go test ./test/... -v
```

### Run specific module tests:
```bash
# Test App Connector Group module
go test ./test/terraform-zpa-app-connector-group -v

# Test Provisioning Key module
go test ./test/terraform-zpa-provisioning-key -v
```

### Run specific test functions:
```bash
# Run only validation tests
go test ./test/terraform-zpa-app-connector-group -v -run TestValidate

# Run only plan tests
go test ./test/terraform-zpa-app-connector-group -v -run TestPlan

# Run only apply tests
go test ./test/terraform-zpa-app-connector-group -v -run TestApply
```

## Test Functions

Each module test includes the following test functions:

- **TestValidate**: Validates Terraform configuration syntax
- **TestPlan**: Runs `terraform plan` to check for errors
- **TestApply**: Deploys infrastructure and verifies outputs
- **TestIdempotence**: Verifies that subsequent applies don't make changes

## Environment Variables

Set the following environment variables before running tests:

```bash
# Replace with your actual Zscaler OneAPI credentials
export ZSCALER_CLIENT_ID="your-client-id"  # pragma: allowlist secret
export ZSCALER_CLIENT_SECRET="your-client-secret"  # pragma: allowlist secret
export ZSCALER_VANITY_DOMAIN="your-vanity-domain"
export ZPA_CUSTOMER_ID="your-customer-id"
export ZSCALER_CLOUD="production"  # e.g., "production", "beta"
```

## Test Configuration

Tests use realistic default values but can be customized by modifying the `Vars` map in each `main_test.go` file.

## Cleanup

Tests automatically clean up resources after each test run using `defer terraform.Destroy()`.
