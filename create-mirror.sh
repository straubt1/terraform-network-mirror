#!/bin/bash

set -e -u -o pipefail

[[ $# -eq 0 ]] && echo "Please Pass a Settings File Path" && exit 1

settings_file=$1

platform="linux_amd64"
# platform="darwin_amd64" # if you want to test from a mac
mirror_dir="./mirror"
working_dir=$(pwd)
mkdir -p ${mirror_dir}

download_provider(){
  local provider_namespace=$1
  local provider_name=$2
  local provider_version=$3

  echo "Downloading Terraform Provider ${provider_namespace}/${provider_name}:${provider_version}"
  cat > main.tf << EOF
terraform {
  required_providers {
    ${provider_name} = {
      source  = "${provider_namespace}/${provider_name}"
      version = "${provider_version}"
    }
  }
}
EOF
  terraform providers mirror -platform=${platform} ./
  rm main.tf
}

settings_json=$(cat ${settings_file})
providers=$(echo ${settings_json} | jq '[ .providers[] ]')
provider_names=$(echo ${settings_json} | jq '[ .providers[].name ]')

echo
echo "Mirror Settings:"
echo "  Providers:         ${provider_names}"
echo

echo "Downloading Providers Locally"
cd ${mirror_dir}
for row in $(echo ${providers} | jq -r '.[] | [.namespace, .name, .versions] | @base64'); do
  _namespace() {
    echo ${row} | base64 --decode | jq -r .[0]
  }
  _name() {
    echo ${row} | base64 --decode | jq -r .[1]
  }
  _versions() {
    echo ${row} | base64 --decode | jq -r .[2]
  }

  # echo $(_name) $(_versions)
  for version in $(_versions | jq -r .[]); do
    ns=$(_namespace)
    n=$(_name)
    v=${version}

    download_provider $ns $n $v
  done
done