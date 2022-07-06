#!/usr/bin/bash
sudo yum install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli-exe-linux-x86_64.zip
sudo unzip /tmp/awscli-exe-linux-x86_64.zip -d /tmp
sudo /tmp/aws/install

REGION=$(curl --silent http://169.254.169.254/latest/meta-data/placement/region)
INTERFACE=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
VPC_ID=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/${INTERFACE}/vpc-id)
KEY="ZSAC-"$REGION"-"$VPC_ID

#Stop the App Connector service which was auto-started at boot time
sudo systemctl stop zpa-connector

# Create provisioning key file
echo "Creating Provisioning Key File..."
sudo touch /opt/zscaler/var/provision_key
sudo chmod 644 /opt/zscaler/var/provision_key
sudo chown admin:admin /opt/zscaler/var/ -R

# Retrieve and Decrypt Provisioning Key from Parameter Store
echo "Retrieving Provisioning Key From Parameter Store..."
aws ssm get-parameter --name $KEY --query Parameter.Value --with-decryption --region $REGION | tr -d '"' > /opt/zscaler/var/provision_key

#Run a yum update to apply the latest patches
echo "Installing Latest Patches..."
sudo yum update -y

#Start the App Connector service to enroll it in the ZPA cloud
echo "Restart ZPA Connector Service..."
sudo systemctl start zpa-connector

#Wait for the App Connector to download latest build
sleep 15

#Stop and then start the App Connector for the latest build
sudo systemctl stop zpa-connector
sudo systemctl start zpa-connector