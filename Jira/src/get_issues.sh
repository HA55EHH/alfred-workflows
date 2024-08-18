#!/bin/bash

start_at=0
all_issues="[]"

url="https://$domain/rest/api/3/search"

echo "Sending request to $url to retrieve issues for projects: $projects" >&2

while :
do
    response=$(curl --silent --request POST \
        --url "$url" \
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
        \"maxResults\": 100,
        \"startAt\": $start_at
    }")

    if [ -z "$response" ]; then
        echo "Error: Empty response from the API" >&2
        exit 1
    fi

    issues=$(echo "$response" | jq '[
        .issues[] | {
            title: (.key + " - " + .fields.summary),
            subtitle: (.fields.assignee.displayName + " (" + .fields.status.name + ")"),
            arg: .key
        }
    ]')

    # Concatenate the issues to the all_issues array
    all_issues=$(echo "$all_issues$issues" | jq -s 'add')

    total=$(echo "$response" | jq '.total')
    start_at=$(($start_at + 100))

    if [ $start_at -ge $total ]; then
        break
    fi
done

echo "$all_issues"