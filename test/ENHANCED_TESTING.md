# Enhanced ZPA Testing with ZPAtt Utility

This document describes the enhanced testing capabilities using the ZPA-specific `zpatt` utility, inspired by Palo Alto Networks' `generictt.go` approach.

## What is ZPAtt?

`ZPAtt` (ZPA Terratest) is a ZPA-specific utility that provides:

1. **Standardized ZPA Test Flow**: Apply → Validate → Modify → Plan → Apply → Validate
2. **ZPA Resource Validation**: Ensures ZPA resources are created and modified correctly
3. **Recreate Prevention**: Detects and prevents unnecessary ZPA resource recreation
4. **ZPA-Specific Output Validation**: Validates ZPA ID formats and provisioning keys

## Key Features

### 🔍 **ZPA Resource Change Detection**
```go
// Detects recreate scenarios that could cause service disruption
if hasDel && hasCre {
    t.Errorf(`ZPA Resource about to be deleted and then created again...
    This likely introduces service disruption.`)
}
```

### 🎯 **ZPA-Specific Output Validation**
```go
// Validates ZPA ID format (UUID-like)
func isValidZPAID(id string) bool {
    uuidRegex := regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)
    return uuidRegex.MatchString(strings.ToLower(id))
}

// Validates Provisioning Key format
func isValidProvisioningKey(key string) bool {
    validChars := regexp.MustCompile(`^[A-Za-z0-9+/=]+$`)
    return validChars.MatchString(key)
}
```

### 🔄 **State Change Testing**
```go
// Test parameter changes without recreation
changes := map[string]interface{}{
    "app_connector_group_latitude":  "40.7128",  // New York
    "app_connector_group_longitude": "-74.0060",
    "app_connector_group_location": "New York, NY, USA",
}
zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
```

## Test Scenarios Covered

### **App Connector Group Tests:**

#### **1. Basic Validation**
- ✅ Resource creation
- ✅ Output validation (ID format)
- ✅ Parameter validation

#### **2. Location Changes**
- ✅ Latitude/Longitude updates
- ✅ Location description changes
- ✅ Ensures updates, not recreates

#### **3. Version Profile Changes**
- ✅ Version profile ID changes
- ✅ Override profile settings
- ✅ Ensures updates, not recreates

#### **4. Configuration Changes**
- ✅ Description updates
- ✅ DNS query type changes
- ✅ Upgrade day/time changes
- ✅ Country code changes

### **Provisioning Key Tests:**

#### **1. Key Creation**
- ✅ New key generation
- ✅ Key format validation
- ✅ Association type validation

#### **2. Key Modification**
- ✅ Usage limit changes
- ✅ Enabled/disabled state changes
- ✅ Ensures updates, not recreates

#### **3. BYO (Bring Your Own) Scenarios**
- ✅ Existing key usage
- ✅ Key selection validation

## Usage Examples

### **Basic Enhanced Test:**
```go
func TestZPAEnhancedValidation(t *testing.T) {
    terraformOptions := CreateEnhancedTerraformOptions(t)
    
    checkFunc := func(t *testing.T, terraformOptions *terraform.Options) {
        appConnectorGroupId := terraform.Output(t, terraformOptions, "app_connector_group_id")
        assert.NotEmpty(t, appConnectorGroupId, "App Connector Group ID should not be empty")
    }
    
    zpatt.ZPATest(t, terraformOptions, checkFunc)
}
```

### **Parameter Change Test:**
```go
func TestZPALocationChange(t *testing.T) {
    terraformOptions := CreateEnhancedTerraformOptions(t)
    
    changes := map[string]interface{}{
        "app_connector_group_latitude":  "40.7128",
        "app_connector_group_longitude": "-74.0060",
        "app_connector_group_location": "New York, NY, USA",
    }
    
    zpatt.TestZPAModuleWithChanges(t, terraformOptions, changes)
}
```

## Benefits Over Basic Tests

### **✅ Advanced Validation:**
- ZPA-specific ID format validation
- Provisioning key format validation
- Resource state change validation

### **✅ Recreate Prevention:**
- Detects unnecessary resource recreation
- Prevents service disruption
- Validates update vs. recreate scenarios

### **✅ Comprehensive Testing:**
- Tests parameter modifications
- Validates state changes
- Ensures idempotence

### **✅ ZPA-Specific Features:**
- Location coordinate validation
- Version profile validation
- DNS query type validation
- Provisioning key format validation

## Running Enhanced Tests

### **Run All Enhanced Tests:**
```bash
go test ./test/terraform-zpa-app-connector-group -v -run TestZPA
```

### **Run Specific Enhanced Tests:**
```bash
# Test location changes
go test ./test/terraform-zpa-app-connector-group -v -run TestZPALocationChange

# Test version profile changes
go test ./test/terraform-zpa-app-connector-group -v -run TestZPAVersionProfileChange

# Test description changes
go test ./test/terraform-zpa-app-connector-group -v -run TestZPADescriptionChange
```

## Comparison with Palo Alto Networks Approach

| Feature | Palo Alto Networks | ZPA Enhanced |
|---------|-------------------|--------------|
| **Resource Types** | AWS (EC2, VPC, etc.) | ZPA (App Connector, Provisioning Key) |
| **Validation** | AWS resource validation | ZPA ID/key format validation |
| **Change Detection** | AWS recreate detection | ZPA recreate prevention |
| **Output Validation** | Generic "false" detection | ZPA-specific format validation |
| **State Testing** | AWS resource modifications | ZPA parameter modifications |

## Conclusion

The ZPAtt utility provides ZPA-specific testing capabilities that:

1. **Prevent Service Disruption**: Detects and prevents unnecessary ZPA resource recreation
2. **Validate ZPA Formats**: Ensures ZPA IDs and keys are in correct format
3. **Test State Changes**: Validates parameter modifications work correctly
4. **Ensure Idempotence**: Verifies that subsequent applies don't make unnecessary changes

This approach is **highly recommended** for production ZPA module testing as it provides comprehensive validation while preventing service disruptions.
