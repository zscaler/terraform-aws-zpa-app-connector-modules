################################################################################
# Retrieve the "Connector" enrollment certificate used to sign App Connector
# provisioning keys. This module exclusively provisions App Connectors of type
# "Connector", so the certificate name is intentionally hardcoded and not
# exposed as a variable.
################################################################################
data "zpa_enrollment_cert" "connector" {
  name = "Connector"
}

################################################################################
# Create ZPA App Connector Provisioning Key
################################################################################
resource "zpa_provisioning_key" "provisioning_key" {
  count              = var.byo_provisioning_key == false ? 1 : 0
  name               = var.provisioning_key_name
  enabled            = var.provisioning_key_enabled
  association_type   = var.provisioning_key_association_type
  max_usage          = var.provisioning_key_max_usage
  enrollment_cert_id = data.zpa_enrollment_cert.connector.id
  zcomponent_id      = var.app_connector_group_id
}

# Or use existing Provisioning Key if specified in byo_provisioning_key_name
data "zpa_provisioning_key" "provisioning_key_selected" {
  name             = var.byo_provisioning_key == false ? zpa_provisioning_key.provisioning_key[0].name : var.byo_provisioning_key_name
  association_type = var.provisioning_key_association_type
}
