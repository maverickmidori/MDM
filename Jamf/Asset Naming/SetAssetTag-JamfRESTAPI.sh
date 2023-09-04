#!/bin/bash
################## { L O G G I N G } ##################
exec 1> >(logger -s -t $(basename $0)) 2>&1
################## { V A R I A B L E S } ##################
Username= # See PASSWORD VAULT
Password= # See PASSWORD VAULT
Server="https://avondalecollege.jamfcloud.com:443"
serial=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
response=$(curl -k -H "accept: application/xml" -u $Username:$Password $Server/JSSResource/computers/serialnumber/${serial}/subset/general)
assetTag=$(echo $response | /usr/bin/awk -F'<asset_tag>|</asset_tag>' '{print $2}');
barcode1=$(echo $response | /usr/bin/awk -F'< barcode_1 >|</barcode_1 >' '{print $2}');
barcode2=$(echo $response | /usr/bin/awk -F'< barcode_2 >|</barcode_2 >' '{print $2}');
computerName=$assetTag
################## { F U N C T I O N S } ##################
scutil=(
    "ComputerName" 
    "HostName"
    "LocalHostName"
    )
function ComputerName() {
    declare -a scutil=("${!1}")
    for arg in "${scutil[@]}"
    do
    echo "[I] INFO: Setting $arg to $computerName"
    # scutil --set $arg "$computerName"
    if [ ! $(scutil --get $arg) = $computerName ]
    then echo "[E] ERROR: Failed to Set $arg" >&2
    else echo "[I] INFO: $arg Modified Succesfully"
    fi
done }
################## { E X E C U T I O N } ##################
ComputerName scutil[@]
################## { E N D   O F   F I L E } ##################
