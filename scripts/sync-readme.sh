#!/bin/bash
readonly workflow_dir="${1}"
readonly info_plist="${workflow_dir}/info.plist"

if [[ "$#" -ne 1 ]] || [[ ! -f "${info_plist}" ]]; then
  echo 'You need to give this script a single argument: the path to a valid workflow directory.'
  exit 1
fi

# Extract the readme key if it exists and create a README.md file
if /usr/libexec/PlistBuddy -c 'print readme' "${info_plist}" &> /dev/null; then
  readonly readme_content="$(/usr/libexec/PlistBuddy -c 'print readme' "${info_plist}")"
  echo "${readme_content}" > "${workflow_dir}/README.md"
  echo "README.md created with the contents of the readme key."
else
  echo "No readme key found in info.plist."
fi