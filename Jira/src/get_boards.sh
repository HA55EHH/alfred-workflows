#!/bin/zsh

max_results=50
all_boards="[]"
start_at=0

base_url="https://$domain/rest/agile/1.0/board"

while true; do
    url="$base_url?maxResults=$max_results&startAt=$start_at"
    echo "Sending request to $url" >&2

    response=$(curl --silent --request GET \
        --url "$url" \
        --user "$email:$api_token" \
        --header "Accept: application/json")

    if [ -z "$response" ]; then
        echo "Error: No response received from the server." >&2
        break
    fi

    boards=$(echo "$response" | jq '[.values[] | {
        title: .location.projectKey,
        subtitle: .location.projectName,
        arg: "\(.id),\(.location.projectKey)"
    }]')

    # Concatenate the boards to the all_boards array
    all_boards=$(echo "$all_boards" "$boards" | jq -s 'add')

    total=$(echo "$response" | jq '.total')
    start_at=$(($start_at + $max_results))

    # Break if we've processed all boards
    if [ $start_at -ge $total ]; then
        break
    fi
done

echo "$all_boards"