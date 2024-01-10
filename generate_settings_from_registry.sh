#!/usr/bin/env bash
reg="https://registry.terraform.io/v1/providers"

gen_json(){
namespace=${1:-"hashicorp"}
provider=${2:-"aws"}
echo "generate version json files for namespace: $namespace, provider: $provider"
v=$(curl -s "$reg/$namespace/$provider/versions" -q|jq  '[.versions[].version] | sort_by(.)')
 jq > ${namespace}-${provider}.json << EOF
{
    "providers": [{
            "namespace": "$namespace",
            "name": "$provider",
            "versions": $v
        }
    ]
}
EOF
}
gen_json $@
