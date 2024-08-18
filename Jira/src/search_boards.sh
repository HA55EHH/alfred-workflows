#!/bin/bash

# Search query i.e. everything typed after the keyword
query="$1"

# store cache file in workflow cache (alfred_ variables are default workflow variables)
cache_file="$alfred_workflow_cache/board-cache.json"

# create the directory if it doesn't already exist
mkdir -p "$alfred_workflow_cache"

# Check if the cache file exists, if not, trigger api.sh
echo "Checking for cache file in: $cache_file" >&2
if [ ! -f "$cache_file" ]; then
    echo "Cannot find cache file. Querying Jira API." >&2
    ./src/get_boards.sh > "$cache_file"
fi

cache_content=$(jq -c '.' < "$cache_file")

# Pre-filters the projects to those defined in the workflow configuration
if [ "$filter_projects" = 1 ]; then
    # Convert $projects to a jq array
    projects_array=$(echo "$projects" | jq -R 'split(",")')
    
    # Filter cache_content to include only those whose title matches the projects array
    cache_content=$(echo "$cache_content" | jq --argjson projects "$projects_array" '[.[] | select(.title | IN($projects[]))]')
fi

# Concatenate title, subtitle, and arg with tabs. 
cache_content=$(echo "$cache_content" | jq -r '.[] | "\(.title)\t\(.subtitle)\t\(.arg)"')

# Filter the contents of ~/projects-cache.json, querying name only by using concatenated
# name, key and id then telling fzf to split on tab and query only the first result. We
# require name, key and id in the result, hence the concat.
result=$(echo "$cache_content" | fzf --with-nth=1 --delimiter="\t" --filter="$query")


# Split the result back into name, key and id results, put them into an array and
# finally pretty print the array
items=$(
    jq -nR 'inputs | split("\t") | {title: .[0], subtitle: .[1], arg: .[2]}' <<< "$result" |
    jq -cs '{items: .}' |
    jq '.items |= map(select(.title != null))'
)

# If items is empty, add a default command to search Jira boards via the browser
items=$(
    echo "$items" | jq '
    if .items | length == 0 then
        .items += [{"title": "Search Projects", "subtitle": "Search projects for '"$query"'", "arg": "<null>,'"$query"'"}]
    else
        .
    end'
)


# Output the final JSON structure to Alfred
cat << EOB
$items
EOB