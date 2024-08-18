#!/bin/zsh
readonly workflow_dir="${1}"
readonly plist="${workflow_dir}/info.plist"

if [[ "$#" -ne 1 ]] || [[ ! -f "${plist}" ]]; then
  echo 'You need to provide a single argument: the path to a valid workflow directory.'
  exit 1
fi

readonly workflow_name="$(/usr/libexec/PlistBuddy -c 'print name' "${plist}")"
readonly workflow_file="${workflow_dir}/${workflow_name}.alfredworkflow"

if /usr/libexec/PlistBuddy -c 'print variablesdontexport' "${plist}" &> /dev/null; then
  readonly workflow_dir_to_package="$(mktemp -d)"
  /bin/cp -R "${workflow_dir}/"* "${workflow_dir_to_package}"

  readonly tmp_plist="${workflow_dir_to_package}/info.plist"
  /usr/libexec/PlistBuddy -c 'Print variablesdontexport' "${tmp_plist}" | \
    grep '    ' | \
    sed -E 's/ {4}//' | \
    xargs -I {} /usr/libexec/PlistBuddy -c "Set variables:'{}' ''" "${tmp_plist}"
else
  readonly workflow_dir_to_package="${workflow_dir}"
fi

DITTONORSRC=1 /usr/bin/ditto -ck "${workflow_dir_to_package}" "${workflow_file}"
/usr/bin/zip "${workflow_file}" --delete 'prefs.plist' > /dev/null
echo "Exported worflow to ${workflow_file}."