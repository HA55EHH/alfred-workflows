#!/bin/bash

# Search query i.e. everything typed after the keyword
query="$1"

# Store cache file in workflow cache (alfred_ variables are default workflow variables)
cache_file="$alfred_workflow_cache/issue-cache.json"

# Create the directory if it doesn't already exist
mkdir -p "$alfred_workflow_cache"

# Check if the cache file exists, if not, create
echo "Checking for cache file in: $cache_file" >&2
if [ ! -f "$cache_file" ]; then
    echo "Cannot find cache file. Querying Jira API." >&2
    ./src/get_issues.sh > "$cache_file"
fi

echo "Found cache: $cache_file" >&2

# Load the contents of issue-cache.json into a variable
cache_content=$(jq -r '.[] | "\(.title)\t\(.subtitle)\t\(.arg)"' < "$cache_file")

# Filter the contents of issue-cache.json, querying title only by concatenating
# title, subtitle and arg with tabs then telling fzf to split on tab and query only the
# first result. We require title, subtitle and arg in the result, hence the concat.
result=$(echo "$cache_content" | fzf --with-nth=1 --delimiter="\t" --filter="$query")

# Split the result back into title, subtitle and arg results, put them into an array and
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
