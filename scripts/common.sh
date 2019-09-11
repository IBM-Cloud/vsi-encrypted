function check_exists {
  if echo "$1" | grep -q "not found"; then
    return 1
  fi
  if echo "$1" | grep -q "crn:v1"; then
    return 0
  fi
  echo "Failed to check if object exists: $1"
  exit 2
}
function check_value {
  if [ -z "$1" ]; then
    exit 1
  fi

  if echo $1 | grep -q -i "failed"; then
    exit 2
  fi
}

# Returns a service CRN given a service name
function get_instance_id {
  OUTPUT=$(ibmcloud resource service-instance --output JSON $1)
  if (echo $OUTPUT | grep -q "crn:v1" >/dev/null); then
    echo $OUTPUT | jq -r .[0].id
  else
    echo "Failed to get instance ID: $OUTPUT"
    exit 2
  fi
}

# Returns a service GUID given a service name
function get_guid {
  OUTPUT=$(ibmcloud resource service-instance --id $1)
  if (echo $OUTPUT | grep -q "crn:v1" >/dev/null); then
    echo $OUTPUT | awk -F ":" '{print $8}'
  else
    echo "Failed to get GUID: $OUTPUT"
    exit 2
  fi
}
function get_ibmcloud_api_key() {
  jq -r '.apikey' apikey.json
}
function get_kp_key_id() {
  kp_guid=$1
  kp_key_name=$2
  ibmcloud kp list --instance-id $kp_guid  --output json | jq -e -r '.[] | select(.name=="'$kp_key_name'") | .id'
}

# cloud block storage is identified by the string: server-protect
function get_cloud_block_storage_to_kms_guid_authorization() {
  kp_guid=$1
  ibmcloud iam authorization-policies --output JSON |
    jq -r -e '.[] | select(.subjects[].attributes[].value=="server-protect") |
      select(.roles[].display_name=="Reader") | 
      select(.resources[].attributes[].value=="kms") |
      select(.resources[].attributes[].value=="'$kp_guid'") |
      .id'
}
