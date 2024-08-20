#!/bin/zsh
query=$1

readonly cache_file="${alfred_workflow_cache}/user_repos.json"

echo "Looking for cache: $cache_file" >&2

if [[ -f "${cache_file}" ]]; then

echo "Found cache: $cache_file" >&2

# Load the conte# Load the contents of issue-cache.json into a variable
cache_content=$(jq -r '.[] | "\(.title)\t\(.subtitle)\t\(.arg)"' < "$cache_file")

# Filter the contents of issue-cache.json, querying title only by concatenating
# title, subtitle, arg, and icon path with tabs then telling fzf to split on tab and query only the
# first result. We require title, subtitle, arg, and icon in the result, hence the concat.
result=$(echo "$cache_content" | fzf --with-nth=1 --delimiter="\t" --filter="$query")

# Split the result back into title, subtitle, arg, and icon results, put them into an array and
# finally pretty print the array
items=$(
    jq -nR 'inputs | split("\t") | {title: .[0], subtitle: .[1], arg: .[2]}' <<< "$result" |
    jq -cs '{items: .}' |
    jq '.'
)
# Output the final JSON structure to Alfred
cat << EOB
$items
EOB
fi


echo '{ "items": [{
  "title": "Update user repository cache.",
  "subtitle": "Send a request to the GitHub API",
  "arg": "update_items"
}] }'