#!/bin/bash
file="$alfred_workflow_cache/issues-cache.json"

# create the directory if it doesn't already exist
mkdir -p "$alfred_workflow_cache"

echo "Updating $file for projects: $projects." >&2
max_results=100
start_at=0
total=1  # initialize total to enter the loop
all_issues="[]"  # initialize an empty JSON array

while [ $start_at -lt $total ]
do
    response=$(curl --silent --request POST \
        --url "https://$domain/rest/api/3/search" \
        --user "$email:$api_token" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --data "{
            \"fields\": [
            \"summary\",
            \"status\",
            \"assignee\"
        ],
        \"fieldsByKeys\": false,
        \"jql\": \"project in ($projects) and statusCategory!=Done\",
        \"maxResults\": $max_results,
        \"startAt\": $start_at
    }")

    issues=$(
    echo "$response" | jq '[
        .issues[] | {
            title: (.key + " - " + .fields.summary),
            subtitle: (.fields.assignee.displayName + " (" + .fields.status.name + ")"),
            arg: .key
        }
    ]'
    )

    # Concatenate the issues to the all_issues array
    all_issues=$(echo "$all_issues$issues" | jq -s 'add')

    total=$(echo "$response" | jq '.total')
    start_at=$(($start_at + $max_results))

done

echo "$all_issues" > "$file"
echo "$file updated!" >&2