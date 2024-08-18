#!/bin/zsh
readonly workflow_dir="${1}"
readonly info_plist="${workflow_dir}/info.plist"

if [[ "$#" -ne 1 ]] || [[ ! -f "${info_plist}" ]]; then
  echo 'You need to provide a single argument: the path to a valid workflow directory.'
  exit 1
fi

# Extract and display the current version
if /usr/libexec/PlistBuddy -c 'print version' "${info_plist}" &> /dev/null; then
  readonly current="$(/usr/libexec/PlistBuddy -c 'print version' "${info_plist}")"
  echo "Current version: ${current}"
else
  echo "No version key found in info.plist."
  exit 1
fi

# Prompt the user for a new version
read -p "Enter the new version: " new

# Validate the new version format e.g. 0.0.1
if [[ ! "${new}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version format."
  exit 1
fi

# Compare old and new versions to ensure new version > old version
if [[ "$new" == "$current" ]] || 
   [[ "$(printf '%s\n' "$current" "$new" | sort -V | head -n1)" == "$new" ]]; then
  echo "New version (${new}) must be greater than the current version (${current})."
  exit 1
fi

echo "Valid version format: ${new}."

# The script could proceed to update the version if desired
/usr/libexec/PlistBuddy -c "Set :version ${new}" "${info_plist}"

# make sure readme is up to date
./scripts/sync-readme.sh "$workflow_dir"

# create .alfredworkflow
./scripts/package.sh "$workflow_dir"
