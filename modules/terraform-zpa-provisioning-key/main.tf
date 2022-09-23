################################################################################
# Create ZPA App Connector Provisioning Key
################################################################################
# Retrieve Connector Enrollment Cert ID
data "zpa_enrollment_cert" "connector_cert" {
  name = var.enrollment_cert
}

# Create App Connector provisioning key
resource "zpa_provisioning_key" "provisioning-key" {
  count              = var.byo_provisioning_key == false ? 1 : 0
  name               = var.provisioning_key_name
  enabled            = var.provisioning_key_enabled
  association_type   = var.provisioning_key_association_type
  max_usage          = var.provisioning_key_max_usage
  enrollment_cert_id = data.zpa_enrollment_cert.connector_cert.id
  zcomponent_id      = var.app_connector_group_id
}

# Or use existing Provisioning Key if specified in byo_provisioning_key_name
data "zpa_provisioning_key" "provisioning-key-selected" {
  name             = var.byo_provisioning_key == false ? zpa_provisioning_key.provisioning-key[0].name : var.byo_provisioning_key_name
  association_type = var.provisioning_key_association_type
}