# # General
region = "ca-central-1"
name   = "zpa-example"
global_tags = {
  ManagedBy   = "Terraform"
  Application = "Zscaler Private Access"
}

# # Security Groups
security_vpc_security_groups = {
  zpa_app_connector_mgmt = {
    name = "zpa_app_connector_mgmt"
    rules = {
      all_outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ssh = {
        description = "Allow SSH to App Connector VM"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
    }
  }
}

### NAT gateway
nat_gateway_name = "example-natgw"

# # VPC
security_vpc_name = "security-vpc-example"
security_vpc_cidr = "10.100.0.0/16"

# # Routes
security_vpc_routes_outbound_destin_cidrs = ["0.0.0.0/0"]

# Security VPC Subnets
security_vpc_subnets = {
  # Do not modify value of `set=`, it is an internal identifier referenced by main.tf.
  "10.100.0.0/24"  = { az = "ca-central-1a", set = "mgmt" }
  "10.100.5.0/24"  = { az = "ca-central-1a", set = "natgw" }
}

# # ZPA App Connector VM
ssh_key_name         = "example-ssh-key"
appconnector_version = "2021.06"
appconnector-vm = {
  appconnector-vm01 = { az = "ca-central-1a" }
}

bootstrap_options    = "user_data.sh"
iam_instance_profile = "ZPA_Instance_Profile"

# # ZPA App Connector Group
app_connector_group_enabled                  = true
app_connector_group_country_code             = "US"
app_connector_group_latitude                 = "37.3382082"
app_connector_group_longitude                = "-121.8863286"
app_connector_group_location                 = "San Jose, CA, USA"
app_connector_group_upgrade_day              = "SUNDAY"
app_connector_group_upgrade_time_in_secs     = "66600"
app_connector_group_override_version_profile = true
app_connector_group_version_profile_id       = "2"
app_connector_group_dns_query_type           = "IPV4_IPV6"


# # ZPA App Connector Provisioning Key
provisioning_key_association_type = "CONNECTOR_GRP"
provisioning_key_max_usage        = 50

path_to_public_key = "./local.pub"