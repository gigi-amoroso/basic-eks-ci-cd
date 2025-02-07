#!/bin/bash
set -e

echo "Retrieving the only hosted zone in your account..."
# Get the first hosted zone from Route 53
HOSTED_ZONE_JSON=$(aws route53 list-hosted-zones --query "HostedZones[0]" --output json)
if [ -z "$HOSTED_ZONE_JSON" ]; then
  echo "No hosted zones found."
  exit 1
fi

# Extract hosted zone ID (strip the '/hostedzone/' prefix) and name.
HOSTED_ZONE_ID=$(echo "$HOSTED_ZONE_JSON" | jq -r '.Id' | sed 's|/hostedzone/||')
HOSTED_ZONE_NAME=$(echo "$HOSTED_ZONE_JSON" | jq -r '.Name')
echo "Found hosted zone: ${HOSTED_ZONE_NAME} (ID: ${HOSTED_ZONE_ID})"

# Write these values into generated.auto.tfvars so Terraform can pick them up automatically.
echo "Writing values to generated.auto.tfvars..."
cat > generated.auto.tfvars <<EOF
domain_name   = "${HOSTED_ZONE_NAME}"
hosted_zone_id = "${HOSTED_ZONE_ID}"
EOF
echo "generated.auto.tfvars created with domain_name = ${HOSTED_ZONE_NAME} and hosted_zone_id = ${HOSTED_ZONE_ID}"

echo "Listing CNAME records in hosted zone ${HOSTED_ZONE_NAME}..."
# List all CNAME records in the hosted zone.
RECORDS_JSON=$(aws route53 list-resource-record-sets \
  --hosted-zone-id "${HOSTED_ZONE_ID}" \
  --query "ResourceRecordSets[?Type=='CNAME']" \
  --output json)

NUM_RECORDS=$(echo "$RECORDS_JSON" | jq 'length')
echo "Found ${NUM_RECORDS} CNAME record(s)."

# Loop over each CNAME record and import it.
for i in $(seq 0 $(($NUM_RECORDS - 1))); do
  RECORD_NAME=$(echo "$RECORDS_JSON" | jq -r ".[$i].Name")
  # Construct the Terraform import ID in the format: <hosted_zone_id>__<record_name>_<record_type>
  IMPORT_ID="${HOSTED_ZONE_ID}__${RECORD_NAME}_CNAME"
  # Use the record name without the trailing dot as the for_each key.
  FOR_EACH_KEY=$(echo "$RECORD_NAME" | sed 's/\.$//')
  
  echo "Importing record ${RECORD_NAME} with key '${FOR_EACH_KEY}' using import ID: ${IMPORT_ID}"
  terraform import aws_route53_record.cert_validation["${FOR_EACH_KEY}"] "${IMPORT_ID}"
done

echo "All CNAME records imported."
