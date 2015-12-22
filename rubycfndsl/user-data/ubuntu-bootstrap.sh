# #!/bin/bash -ex

# ################################################################################
# # Bootstrap

# # The bootstrap log file:
# LOG_FILE=/var/log/bootstrap.log

# # Script error handling and output redirect
# set -e                               # Fail on error
# set -o pipefail                      # Fail on pipes
# exec >> $LOG_FILE                    # stdout to log file
# exec 2>&1                            # stderr to log file
# set -x                               # Bash verbose

# ################################################################################
# # Install ansible,wget,pip,awscli

if ! which aws || ! which ansible; then
  apt-get clean
  apt-get update
  apt-get install -y ansible wget python-pip
  pip install awscli
fi

# ################################################################################
# # Get metadata from tags

export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

export ANSIBLE_ROLE=$(aws ec2 describe-tags --region eu-west-1 \
  --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=AnsibleRole" | \
  grep Value|sed -r 's%.*Value": "(.*)",.*%\1%g')

export BUCKET_NAME=$(aws ec2 describe-tags --region eu-west-1 \
  --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=BucketName" | \
  grep Value|sed -r 's%.*Value": "(.*)",.*%\1%g')

export APPLICATION=$(aws ec2 describe-tags --region eu-west-1 \
  --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=Application" | \
  grep Value|sed -r 's%.*Value": "(.*)",.*%\1%g')

export ENVIRONMENT=$(aws ec2 describe-tags --region eu-west-1 \
  --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=Environment" | \
  grep Value|sed -r 's%.*Value": "(.*)",.*%\1%g')

# ################################################################################
# # Create ee-microdc configuration file

echo ANSIBLE_ROLE=${ANSIBLE_ROLE} > /etc/default/ee-microdc
echo BUCKET_NAME=${BUCKET_NAME} >> /etc/default/ee-microdc
echo INSTANCE_ID=${INSTANCE_ID} >> /etc/default/ee-microdc
echo APPLICATION=${APPLICATION} >> /etc/default/ee-microdc
echo ENVIRONMENT=${ENVIRONMENT} >> /etc/default/ee-microdc

# ################################################################################
# # Build bucket URL

export BUCKET_URL="s3://${BUCKET_NAME}/${APPLICATION}/${ENVIRONMENT}"

################################################################################
# Download Ansible manifests and run it

# Remove requiretty
sed -ri '/requiretty/d' /etc/sudoers

# Deploy ansible
mkdir -p /opt/ansible
cd /opt/ansible 
aws s3 cp ${BUCKET_URL}/ansible/ansible-playbook-${ANSIBLE_ROLE}.tar.gz -|tar zxvf -
aws s3 cp ${BUCKET_URL}/ansible/version .

# Run it
ansible-playbook --connection=local -i environments/${ENVIRONMENT}/inventory playbooks/${ANSIBLE_ROLE}.yml 

#exit 0


