## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

#####################################################################################################################
##### Variables 2-9 are populated automically if terraform is ran via ZSAC bash script.   ##### 
##### Modifying the variables in this file will override any inputs from ZSAC             #####
#####################################################################################################################

#####################################################################################################################
##### Zscaler ZPA Provider credentials. These may be automatically populated if using zsac  #####
#####################################################################################################################

## 1. Uncomment and enter values valid for your ZPA environment. 
##    Details on how to find and generate ZPA API keys can be located here: https://help.zscaler.com/zpa/about-api-keys#:~:text=An%20API%20key%20is%20required,from%20the%20API%20Keys%20page

#zpa_client_id                                = "zpa-api-client-id"
#zpa_client_secret                            = "zpa-api-client-secret"
#zpa_customer_id                              = "zpa-tenant-id"


## ZPA App Connector Group variables. Uncomment and replace values as desired for your deployment
#app_connector_group_name                     = "group_name"
#app_connector_group_description              = "group_description"
#app_connector_group_enabled                  = true
#app_connector_group_country_code             = "US"
#app_connector_group_latitude                 = "37.3382082"
#app_connector_group_longitude                = "-121.8863286"
#app_connector_group_location                 = "San Jose, CA, USA"
#app_connector_group_upgrade_day              = "SUNDAY"
#app_connector_group_upgrade_time_in_secs     = "66600"
#app_connector_group_override_version_profile = true
#app_connector_group_version_profile_id       = "2"
#app_connector_group_dns_query_type           = "IPV4_IPV6"


## ZPA App Connector Provisioning Key variables
#enrollment_cert                               = "Connector"
#provisioning_key_name                         = "key_name"
#provisioning_key_enabled                      = true
#provisioning_key_max_usage                    = 50


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 2. AWS region where App Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: us-west-2)

#aws_region                                 = "us-west-2"

## 3. App Connector AWS EC2 Instance size selection. Uncomment acvm_instance_type line with desired vm size to change.
##    (Default: m5a.xlarge)

#acvm_instance_type                         = "t3.xlarge"  # recommended only for test/non-prod use
#acvm_instance_type                         = "m5a.xlarge"

## 4. The number of App Connector Subnets to create in sequential availability zones. Available input range 1-3 (Default: 2)
##    **** NOTE - This value will be ignored if byo_vpc / byo_subnets

#az_count                                   = 2

## 5. The number of App Connector appliances to provision. Each incremental App Connector will be created in alternating 
##    subnets based on the az_count or byo_subnet_ids variable and loop through for any deployments where ac_count > az_count.
##    (Default: varies per deployment type template)
##    E.g. ac_count set to 4 and az_count set to 2 or byo_subnet_ids configured for 2 will create 2x ACs in AZ subnet 1 and 2x ACs in AZ subnet 2

#ac_count                                   = 2

## 6. Network Configuration:

##    IPv4 CIDR configured with VPC creation. All Subnet resources (Public / App Connector) will be created based off this prefix
##    /24 subnets are created assuming this cidr is a /16. If you require creating a VPC smaller than /16, you may need to explicitly define all other 
##     subnets via public_subnets and ac_subnets variables

##    Note: This variable only applies if you let Terraform create a new VPC. Custom deployment with byo_vpc enabled will ignore this

#vpc_cidr                                   = "10.1.0.0/16"

##    Subnet space. (Minimum /28 required. Default is null). If you do not specify subnets, they will automatically be assigned based on the default cidrsubnet
##    creation within the VPC CIDR block. Uncomment and modify if byo_vpc is set to true but byo_subnets is left false meaning you want terraform to create 
##    NEW subnets in that existing VPC. OR if you choose to modify the vpc_cidr from the default /16 so a smaller CIDR, you may need to edit the below variables 
##    to accommodate that address space.

##    ***** Note *****
##    It does not matter how many subnets you specify here. this script will only create in order 1 or as many as defined in the az_count variable
##    Default/Minumum: 1 - Maximum: 3
##    Example: If you change vpc_cidr to "10.2.0.0/24", set below variables to cidrs that fit in that /24 like ac_subnets = ["10.2.0.0/27","10.2.0.32/27"] etc.

#public_subnets                             = ["10.x.y.z/24","10.x.y.z/24"]
#ac_subnets                                 = ["10.x.y.z/24","10.x.y.z/24"]

## 7. Tag attribute "Owner" assigned to all resoure creation. (Default: "zsac-admin")

#owner_tag                                  = "username@company.com"

## 8. By default, this script will apply 1 Security Group per App Connector instance. 
##     Uncomment if you want to use the same Security Group for ALL App Connectors (true or false. Default: false)

#reuse_security_group                       = true

## 9. By default, this script will apply 1 IAM Role/Instance Profile per App Connector instance. 
##     Uncomment if you want to use the same IAM Role/Instance Profile for ALL App Connectors (true or false. Default: false)

#reuse_iam                                  = true





