#!/bin/bash
#set -e

# Retrieve the first hosted zone from Route 53.
echo "Retrieving hosted zone..."
HOSTED_ZONE_JSON=$(aws route53 list-hosted-zones --query "HostedZones[0]" --output json)
if [ -z "$HOSTED_ZONE_JSON" ]; then
  echo "No hosted zones found."
  exit 1
fi

# Extract hosted zone ID (remove '/hostedzone/' prefix) and name.
HOSTED_ZONE_ID=$(echo "$HOSTED_ZONE_JSON" | jq -r '.Id' | sed 's|/hostedzone/||')
HOSTED_ZONE_NAME=$(echo "$HOSTED_ZONE_JSON" | jq -r '.Name' | sed 's/\.$//') # return with the dot at the end, thats why sed
echo "Found hosted zone: ${HOSTED_ZONE_NAME} (ID: ${HOSTED_ZONE_ID})"

# Get the AWS account ID automatically.
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: ${ACCOUNT_ID}"

# Write the discovered values to generated.auto.tfvars.
echo "Writing values to generated.auto.tfvars..."
cat > generated.auto.tfvars <<EOF
domain_name    = "${HOSTED_ZONE_NAME}"
hosted_zone_id = "${HOSTED_ZONE_ID}"
acc_id         = "${ACCOUNT_ID}"
EOF
echo "generated.auto.tfvars created with domain_name, hosted_zone_id and acc_id."

# Get the current user
USER_NAME=$(aws sts get-caller-identity --query "Arn" --output text | cut -d'/' -f2)

# Generate a trust policy JSON file using the account ID and user name.
echo "Generating trust policy file (generated_trust_policy.json)..."
cat > generated_trust_policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${ACCOUNT_ID}:user/${USER_NAME}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
echo "generated_trust_policy.json created."

echo "Checking for TerraformExecutionRole..."
if aws iam get-role --role-name TerraformExecutionRole > /dev/null 2>&1; then
  echo "TerraformExecutionRole already exists. Skipping creation."
else
  echo "Creating TerraformExecutionRole..."
  aws iam create-role \
    --role-name TerraformExecutionRole \
    --assume-role-policy-document file://generated_trust_policy.json

  echo "Attaching inline policy from terraform-permissions.json..."
  aws iam put-role-policy \
    --role-name TerraformExecutionRole \
    --policy-name TerraformPermissions \
    --policy-document file://terraform-permissions.json
fi


echo "Listing CNAME records in hosted zone ${HOSTED_ZONE_NAME}..."
RECORDS_JSON=$(aws route53 list-resource-record-sets \
  --hosted-zone-id "${HOSTED_ZONE_ID}" \
  --query "ResourceRecordSets[?Type=='CNAME']" \
  --output json)

NUM_RECORDS=$(echo "$RECORDS_JSON" | jq 'length')
echo "Found ${NUM_RECORDS} CNAME record(s)."

# Loop over each CNAME record.
for i in $(seq 0 $(($NUM_RECORDS - 1))); do
  RECORD_NAME=$(echo "$RECORDS_JSON" | jq -r ".[$i].Name")
  # Remove the trailing dot for matching.
  RECORD_NAME_STRIPPED=$(echo "$RECORD_NAME" | sed 's/\.$//')
  
  # Check if the record is likely a certificate validation record.
  # Here we assume that certificate validation records start with an underscore
  # and contain the hosted zone name.
  if [[ "$RECORD_NAME_STRIPPED" == _*"$HOSTED_ZONE_NAME"* ]]; then
    echo -e "\033[0;31mWarning: Found preexisting certificate validation CNAME record: ${RECORD_NAME}\033[0m"
    echo -e "\033[0;31mThis record may interfere with SSL certificate validation.\033[0m"
  else
    echo "Skipping non-validation record: ${RECORD_NAME}"
  fi
done

echo "Finished processing CNAME records."

echo "Assuming role TerraformExecutionRole..."
ASSUME_ROLE_OUTPUT=$(aws sts assume-role \
  --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/TerraformExecutionRole" \
  --role-session-name "TerraformSession" \
  --duration-seconds 3600)

# Check if the assume-role call was successful
if [ -z "$ASSUME_ROLE_OUTPUT" ]; then
  echo "Failed to assume role TerraformExecutionRole."
  exit 1
fi

# Extract temporary credentials using jq (make sure jq is installed)
export AWS_ACCESS_KEY_ID=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')

echo "Temporary credentials for TerraformExecutionRole have been set."



