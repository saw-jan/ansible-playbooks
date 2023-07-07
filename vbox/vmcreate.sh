#!/bin/bash

# Available args
ARGS='
Available options:
    -n, --name  <string>        name of the vm
    -p, --path  <path>          path to store the vm files
    -i, --iso   <path>          path to the iso file
    -t, --type  <os_type>       type of the guest OS (Ubuntu_64, OpenSUSE_64, Windows10_64, MacOS_64)
    --os-family <os_family>     family of the guest OS (Linux, Windows, MacOS)'

# VARIABLES
VM_NAME=""
VM_PATH=""
VM_ISO=""
VM_TYPE=""
OS_FAMILY=""

while [[ $# -gt 0 ]]; do
    case $1 in
    -n | --name)
        VM_NAME="$2"
        shift 2
        ;;
    -p | --path)
        VM_PATH="$2"
        shift 2
        ;;
    -t | --type)
        VM_TYPE="$2"
        shift 2
        ;;
    -i | --iso)
        VM_ISO="$2"
        shift 2
        ;;
    --os-family)
        OS_FAMILY="$2"
        shift 2
        ;;
    *)
        echo "Unknown option: $1"
        echo "${ARGS}"
        exit 1
        ;;
    esac
done

# check if the path exists
# args:
# - $1    path to check
function pathExist() {
    if [[ ! -d "$1" ]]; then
        echo "Path doesn't exist: $1"
        exit 1
    fi
}

# check if the file exists
# args:
# - $1    file to check
function fileExist() {
    if [[ ! -f "$1" ]]; then
        echo "File doesn't exist: $1"
        exit 1
    fi
}

# add tab to each line
# args:
# - $1    string to format
function formatForCli() {
    str=$(echo "${1}" | sed -e 's/^/\t/')
    echo -e "${str}"
}

# check if the value is empty
# args:
# - $1    value to check
# - $2    error message
function checkValue() {
    if [[ -z "$1" ]]; then
        echo "$2"
        echo "${ARGS}"
        exit 1
    fi
}

checkValue "${VM_NAME}" "[ERR] VM name is required"
checkValue "${VM_PATH}" "[ERR] Path to store the vm files is required"
checkValue "${VM_TYPE}" "[ERR] OS type cannot be empty"

# check if path provided in VM_PATH exists
pathExist "${VM_PATH}"

# check if the ISO file exists
if [[ -n "${VM_ISO}" ]]; then
    fileExist "${VM_ISO}"
fi

if [[ -n "${OS_FAMILY}" ]]; then
    OS_FAMILY_TYPES=$(vboxmanage list ostypes | awk '/^Family ID:/ && !seen[$3]++ {print $3}')
    VALID_FAMILY=$(echo "${OS_FAMILY_TYPES}" | grep -w "${OS_FAMILY}")

    if [[ -z "${VALID_FAMILY}" ]]; then
        echo "Invalid family: ${OS_FAMILY}"
        echo "Valid OS family:"
        formatForCli "${OS_FAMILY_TYPES}"
        exit 1
    fi

    OS_TYPES=$(vboxmanage list ostypes | grep -B 3 -E "Family ID:\s+${OS_FAMILY}" | awk '/^ID:/ {print $2}')
else
    OS_TYPES=$(vboxmanage list ostypes | awk '/^ID:/ {print $2}')
fi

# validate the VM_TYPE
VALID_TYPE=$(echo "${OS_TYPES}" | grep -w "${VM_TYPE}")
if [[ -z "${VALID_TYPE}" ]]; then
    echo "Invalid type: ${VM_TYPE}"
    if [[ -n "${OS_FAMILY}" ]]; then
        echo "Valid OS types for '${OS_FAMILY}':"
    else
        echo "Valid OS types:"
    fi
    formatForCli "${OS_TYPES}"
    exit 1
fi

# If OS_FAMILY is not provided, try to get it from the VM_TYPE
if [[ -z "${OS_FAMILY}" ]]; then
    OS_FAMILY=$(vboxmanage list ostypes | grep -A 3 -E "ID:\s+${VM_TYPE}" | awk '/^Family ID:/ {print $3}')
fi

export VM_NAME
export VM_PATH
export VM_ISO
export VM_TYPE

ansible-playbook vm-playbook.yml
