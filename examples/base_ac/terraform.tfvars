## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

#####################################################################################################################
##### Variables 5-13 are populated automically if terraform is ran via ZSAC bash script.  #####
##### Modifying the variables in this file will override any inputs from ZSAC             #####
#####################################################################################################################

#####################################################################################################################
##### ZPA Provider Resources - OAuth2 Authentication (FULLY AUTOMATED)          #####
##### NOTE: This module now uses OAuth2 user codes for App Connector enrollment #####
##### The provisioning key method is no longer supported (BREAKING CHANGE)      #####
#####################################################################################################################

## DEPLOYMENT WORKFLOW:
## 
## 1. Configure ZPA authentication (environment variables - see below)
## 2. Run: terraform apply -var-file=terraform.tfvars
## 3. Module will:
##    a) Create SSM parameters and VMs
##    b) VMs boot and register OAuth tokens to SSM (2-4 minutes)
##    c) Terraform polls SSM until all tokens are ready
##    d) Creates App Connector Group with tokens
##    e) Enrolls App Connectors via OAuth2 API
## 4. Done! (Total time: ~5-8 minutes)

## 1. AWS Systems Manager Parameter Store for OAuth Token Storage
##    By default, the module CREATES SSM parameters to store OAuth tokens from VMs
##    Uncomment to use existing SSM parameters (BYO - Bring Your Own)
##
##    If using BYO, create parameters named: {base-name}-0, {base-name}-1, etc.
##    Example: If byo_ssm_parameter_name = "/zpa/my-tokens"
##             Module expects: /zpa/my-tokens-0, /zpa/my-tokens-1, ...

#byo_ssm_parameter_name                         = "/zpa/oauth-tokens/my-custom-prefix"

## 2. App Connector onboarding method. Default is "oauth" (recommended): connectors enroll via OAuth2 user codes
##    that each VM publishes to AWS SSM Parameter Store and Terraform reads back to enroll the App Connector Group.
##    Set to "provisioning_key" to use the legacy provisioning key flow instead. The provisioning key is created
##    by the ZPA provider and written into each VM's user_data; no SSM Parameter Store is used in that mode.

#onboarding_method                             = "provisioning_key"

## 2a. ZPA App Connector Provisioning Key variables (only used when onboarding_method = "provisioning_key")
##     https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/zpa_provisioning_key

#provisioning_key_name                         = "new_key_name"
#provisioning_key_enabled                      = true
#provisioning_key_max_usage                    = 10

## 2b. Bring your own existing provisioning key (sets the provisioning key flow automatically)

#byo_provisioning_key                          = true
#byo_provisioning_key_name                     = "example-key-name"

## 3. ZPA App Connector Group variables. Uncomment and replace default values as desired for your deployment.
##    For any questions populating the below values, please reference:
##    https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/zpa_app_connector_group
##
##    NOTE: The App Connector Group will be created AFTER VMs are deployed and OAuth2 tokens are retrieved

## 3a. App Connector Group naming (optional)
##     By default, the name is: {region}-{vpc_id} (e.g., us-west-2-vpc-abc123)
##     
##     You can customize with template variables:
##     - {region}         = AWS region (e.g., us-west-2)
##     - {vpc_id}         = VPC ID (e.g., vpc-abc123)
##     - {name_prefix}    = Your name prefix (e.g., zsdemo)
##     - {random_suffix}  = Random suffix (e.g., abc123)
##
##     Examples:
##     app_connector_group_name = "prod-{region}-{name_prefix}"          → prod-us-west-2-zsdemo
#     app_connector_group_name = "{name_prefix}-{region}-ac-group"      → zsdemo-us-west-2-ac-group
##     app_connector_group_name = "mycompany-{region}-connectors"        → mycompany-us-west-2-connectors
##     
##     Leave empty/commented for default: {region}-{vpc_id}

#app_connector_group_name                       = "{name_prefix}-{region}-ac-group"

## 3b. App Connector Group description and settings

#app_connector_group_description               = "group_description"
#app_connector_group_enabled                   = true
#app_connector_group_country_code              = "US"
#app_connector_group_latitude                  = "37.3382082"
#app_connector_group_longitude                 = "-121.8863286"
#app_connector_group_location                  = "San Jose, CA, USA"
#app_connector_group_city_country              = "San Jose, US"
#app_connector_group_upgrade_day               = "SUNDAY"
#app_connector_group_upgrade_time_in_secs      = "66600"
#app_connector_group_override_version_profile  = true
#app_connector_group_dns_query_type            = "IPV4_IPV6"


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 4. AWS region where App Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: us-west-2)

#aws_region                                     = "us-west-2"

## 5. By default, App Connector will deploy via the Zscaler Latest AMI. Setting this to false will deploy the latest Amazon Linux 2 AMI instead"

#use_zscaler_ami = false

## 6. App Connector AWS EC2 Instance size selection. Uncomment #acvm_instance_type line with desired vm size to change.
##    (Default: m5.large)

#acvm_instance_type                             = "t2.micro"  # recommended only for test/non-prod use
#acvm_instance_type                             = "t3.medium"
#acvm_instance_type                             = "t3.large"
#acvm_instance_type                             = "t3.xlarge"
#acvm_instance_type                             = "t3a.medium"
#acvm_instance_type                             = "t3a.large"
#acvm_instance_type                             = "t3a.xlarge"
#acvm_instance_type                             = "t3a.2xlarge"
#acvm_instance_type                             = "m5.large"
#acvm_instance_type                             = "m5.xlarge"
#acvm_instance_type                             = "m5.2xlarge"
#acvm_instance_type                             = "m5.4xlarge"
#acvm_instance_type                             = "m5a.large"
#acvm_instance_type                             = "m5a.xlarge"
#acvm_instance_type                             = "m5a.2xlarge"
#acvm_instance_type                             = "m5a.4xlarge"
#acvm_instance_type                             = "m5n.large"
#acvm_instance_type                             = "m5n.xlarge"
#acvm_instance_type                             = "m5n.2xlarge"
#acvm_instance_type                             = "m5n.4xlarge"

## 7. The number of App Connector Subnets to create in sequential availability zones. Available input range 1-3 (Default: 2)
##    **** NOTE - This value will be ignored if byo_vpc / byo_subnets

#az_count = 2

## 8. The number of App Connector appliances to provision. Each incremental App Connector will be created in alternating
##    subnets based on the az_count or byo_subnet_ids variable and loop through for any deployments where ac_count > az_count.
##    (Default: varies per deployment type template)
##    E.g. ac_count set to 4 and az_count set to 2 or byo_subnet_ids configured for 2 will create 2x ACs in AZ subnet 1 and 2x ACs in AZ subnet 2

#ac_count = 2

## 9. Enable/Disable public IP addresses on App Connector instances. Default is false. Setting this to true will result in the following:
##    Dynamic Public IP address on the App Connector VM Instance will be enabled;
##    No EIP or NAT Gateway resources will be created;
##    The App Connector Route Table default route next-hop will be set as the IGW

##    Note: App Connector has no external inbound network dependencies, so the recommendation is to leave this set to false and utilize a NAT Gateway
##    for internet egress. Only enable this if you are certain you really want it for you environment.

#associate_public_ip_address                    = true

## 10. Network Configuration:

##    IPv4 CIDR configured with VPC creation. All Subnet resources (Public / App Connector) will be created based off this prefix
##    /24 subnets are created assuming this cidr is a /16. If you require creating a VPC smaller than /16, you may need to explicitly define all other
##     subnets via public_subnets and ac_subnets variables

##    Note: This variable only applies if you let Terraform create a new VPC. Custom deployment with byo_vpc enabled will ignore this

#vpc_cidr = "10.0.0.0/16"

##    Subnet space. (Minimum /28 required. Default is null). If you do not specify subnets, they will automatically be assigned based on the default cidrsubnet
##    creation within the VPC CIDR block. Uncomment and modify if byo_vpc is set to true but byo_subnets is left false meaning you want terraform to create
##    NEW subnets in that existing VPC. OR if you choose to modify the vpc_cidr from the default /16 so a smaller CIDR, you may need to edit the below variables
##    to accommodate that address space.

##    ***** Note *****
##    It does not matter how many subnets you specify here. this script will only create in order 1 or as many as defined in the az_count variable
##    Default/Minumum: 1 - Maximum: 3
##    Example: If you change vpc_cidr to "10.2.0.0/24", set below variables to cidrs that fit in that /24 like ac_subnets = ["10.2.0.0/27","10.2.0.32/27"] etc.

#public_subnets                                 = ["10.0.0.0/24","10.x.y.z/24"]
#ac_subnets                                     = ["10.0.0.0/24","10.x.y.z/24"]

## 11. Tag attribute "Owner" assigned to all resoure creation. (Default: "zsac-admin")

#owner_tag                                      = "username@company.com"

## 12. By default, this script will apply 1 Security Group per App Connector instance.
##     Uncomment if you want to use the same Security Group for ALL App Connectors (true or false. Default: false)

#reuse_security_group                           = true

## 13. By default, this script will apply 1 IAM Role/Instance Profile per App Connector instance.
##     Uncomment if you want to use the same IAM Role/Instance Profile for ALL App Connectors (true or false. Default: false)

#reuse_iam                                      = true

## 14. By default, terraform will always query the AWS Marketplace for the latest App Connector AMI available.
##     This variable is provided if a customer desires to override or retain an old ami for existing deployments rather than upgrading and forcing a replacement. 
##     It is also inputted as a list to facilitate if a customer desired to manually upgrade only select ACs deployed based on the ac_count index

##     Note: Customers should NOT be hard coding AMI IDs as Zscaler recommendation is to always be deploying/running the latest version.
##           Leave this variable commented out unless you are absolutely certain why/that you need to set it and only temporarily.

#ami_id                                         = ["ami-123456789"]
