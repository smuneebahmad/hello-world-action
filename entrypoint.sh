#!/bin/bash

suppressions=$1
checklists=$2
filters=$3
continue_on_failure=$4
use_custom_config=$5
chkk_config_path=$6
chkk_config_file=$7


echo "$suppressions"
echo "$checklists"
echo "$continue_on_failure"
echo "$use_custom_config"
echo "$chkk_config_path"
echo "$chkk_config_file"

echo "printing current dir"
pwd

VERSION=$(curl -sS https://get.chkk.dev/helm/latest.txt) && curl -Lo chkk-post-renderer https://get.chkk.dev/${VERSION}/chkk-post-renderer-alpine
chmod +x chkk-post-renderer


if [ ${use_custom_config} == false ]; then
  touch config.yaml
  cat <<EOF > config.yaml
    continue_on_failure: ${continue_on_failure}
    checklists: []
    suppressions: []
    filters:
      - Secret.data
      - Secret.data.*
EOF
fi

if [ ${checklists} != "[]" ] && [ ${use_custom_config} == false ]; then
  IFS=","; read -a checklistsArray <<< "$checklists";
  for index in "${!checklistsArray[@]}"; do
    val=${checklistsArray[index]};
    yq eval ".checklists += "\"${val}\""" -i config.yaml;
  done;
fi

if [ ${suppressions} != "[]" ] && [ ${use-custom-config} == false ]; then
  IFS=","; read -a suppressionsArray <<< ${suppressions};
  for index in "${!suppressionsArray[@]}"; do
    val=${suppressionsArray[index]};
    yq eval ".suppressions += "\"${val}\""" -i config.yaml;
  done;
fi


if [ ${filters} != "[]" ] && [ ${use_custom_config} == false ]; then
    IFS=","; read -a filtersArray <<< ${filters};
    for index in "${!filtersArray[@]}"; do
      val=${filtersArray[index]};
      yq eval ".filters += "\"${val}\""" -i config.yaml;
    done;
fi

echo "::set-output name=config::config.yaml"
echo "::set-output name=binary::chkk-post-renderer"

echo "CHKK_CONFIG_PATH=${chkk_config_path}" >> $GITHUB_ENV
echo "CHKK_CONFIG_FILE=${chkk_config_file}" >> $GITHUB_ENV
echo "CHKK_ACCESS_TOKEN=${CHKK_ACCESS_TOKEN}" >> $GITHUB_ENV
