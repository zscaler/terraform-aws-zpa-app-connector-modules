## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

#####################################################################################################################
##### Variables 1-17 are populated automically if terraform is ran via ZSAC bash script.   ##### 
##### Modifying the variables in this file will override any inputs from ZSAC             #####
#####################################################################################################################

#####################################################################################################################
##### Cloud Init Userdata Provisioning variables  #####
#####################################################################################################################

## 1. Zscaler App Connector Key E.g. 3|api.private.zscaler.com|<string>

#ac_prov_key = "3|api.private.zscaler.com|<string>"

#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 2. AWS region where App Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone. (Default: us-west-2)

#aws_region                                 = "us-west-2"

## 3. App Connector AWS EC2 Instance size selection. Uncomment acvm_instance_type line with desired vm size to change.
##    (Default: m5a.xlarge)

#acvm_instance_type                       = "t3.xlarge"  # recommended only for test/non-prod use
#acvm_instance_type                       = "m5a.xlarge"

## 4. The number of App Connector Subnets to create in sequential availability zones. Available input range 1-3 (Default: 2)
##    **** NOTE - This value will be ignored if byo_vpc / byo_subnets

#az_count                                   = 2

## 5. The minumum number of App Connectors to maintain in an Autoscaling group. (Default: 2)
##    Recommendation is to maintain HA/Zonal resliency for production deployments

#min_size                                   = 2

## 6. The maximum number of App Connectors to maintain in an Autoscaling group. (Default: 4)

#max_size                                   = 4

## 7. The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service. (Default: 300 seconds/5 minutes)

#health_check_grace_period                  = 300

## 8. Network Configuration:

##    IPv4 CIDR configured with VPC creation. All Subnet resources (Public / App Connector) will be created based off this prefix
##    /24 subnets are created assuming this cidr is a /16. If you require creating a VPC smaller than /16, you may need to explicitly define all other 
##     subnets via public_subnets and ac_subnets variables.

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

## 9. Tag attribute "Owner" assigned to all resoure creation. (Default: "zsac-admin")

#owner_tag                                  = "username@company.com"

## 10. By default, this script will apply 1 Security Group per App Connector instance. 
##     Uncomment if you want to use the same Security Group for ALL App Connectors (true or false. Default: false)

#reuse_security_group                       = true

## 11. By default, this script will apply 1 IAM Role/Instance Profile per App Connector instance. 
##     Uncomment if you want to use the same IAM Role/Instance Profile for ALL App Connectors (true or false. Default: false)

#reuse_iam                                  = true

## 12. If set to true, add a warm pool to the specified Auto Scaling group. See [warm_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#warm_pool).
##     Uncomment to enable. (Default: false)

#warm_pool_enabled                          = true


## 13. Sets the instance state to transition to after the lifecycle hooks finish. Valid values are: Stopped (default), Running or Hibernated. Ignored when 'warm_pool_enabled' is false
##     Uncomment the desired value

#warm_pool_state                            = "Stopped"
#warm_pool_state                            = "Running"
#warm_pool_state                            = "Hibernated"


## 14. Specifies the minimum number of instances to maintain in the warm pool. This helps you to ensure that there is always a certain number of warmed instances available to handle traffic spikes. Ignored when 'warm_pool_enabled' is false
##     Uncomment and specify a desired minimum number of App Connectors to maintain deployed in a warm pool

#warm_pool_min_size                         = 1


## 15. Specifies the total maximum number of instances that are allowed to be in the warm pool or in any state except Terminated for the Auto Scaling group. Ignored when 'warm_pool_enabled' is false
##     Uncomment and specify a desired maximum number of App Connectors to maintain deployed in a warm pool

#warm_pool_max_group_prepared_capacity      = 2


## 16. Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in
##     Uncomment to enable. (Default: false)

#reuse_on_scale_in                          = true


## 17. Target value number for autoscaling policy CPU utilization target tracking. ie: trigger a scale in/out to keep average CPU Utliization percentage across all instances at/under this number
##     (Default: 50%)

#target_cpu_util_value                      = 50