#!/bin/bash

set -e -u -o pipefail

[[ $# -eq 0 ]] && echo "Please Pass a Settings File Path" && exit 1

settings_file=$1

platform="linux_amd64"
# platform="darwin_amd64" # if you want to test from a mac
mirror_dir="./mirror/core"
working_dir=$(pwd)
mkdir -p ${mirror_dir}

download_core(){
  local core_version=$1
  local file_name="terraform_${core_version}_linux_amd64.zip"
  local url="https://releases.hashicorp.com/terraform/${core_version}/terraform_${core_version}_linux_amd64.zip"

  echo "Downloading Terraform Core Version: ${core_version}"
  curl -Lo "${working_dir}/${mirror_dir}/${file_name}" "${url}"
}

settings_json=$(cat ${settings_file})
core_versions=$(echo ${settings_json} | jq '[.core[]]')

echo
echo "Terraform Core Settings:"
echo "  Versions: ${core_versions}"
echo

echo "Downloading Terraform Versions Locally"
cd ${mirror_dir}
for version in $(echo ${core_versions} | jq -r '.[]'); do
  download_core $version
done