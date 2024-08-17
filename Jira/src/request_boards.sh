#!/bin/bash
file="$alfred_workflow_cache/boards-cache.json"

# create the directory if it doesn't already exist
mkdir -p "$alfred_workflow_cache"

echo "Updating $file for boards." >&2

max_results=50
all_boards="[]"
start_at=0
total=1  # initialize total to enter the loop

while [ $start_at -lt $total ]
do
    response=$(curl --silent --request GET \
        --url "https://$domain/rest/agile/1.0/board?maxResults=$max_results&startAt=$start_at" \
        --user "$email:$api_token" \
        --header "Accept: application/json")

    boards=$(echo "$response" | jq '[.values[] | {
        title: .location.projectKey,
        subtitle: .location.projectName,
        arg: "\(.id),\(.location.projectKey)"
    }]')

    # Concatenate the boards to the all_boards array
    all_boards=$(echo "$all_boards$boards" | jq -s 'add')

    total=$(echo "$response" | jq '.total')
    start_at=$(($start_at + $max_results))

done

echo "$all_boards" > "$file"
echo "$file updated!" >&2