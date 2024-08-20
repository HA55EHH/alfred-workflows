#!/bin/zsh

data=$1

# map the original data into alfred items
mapped=$(jq '{items: [.[] | {title: .full_name, subtitle: .description, arg: .html_url}]}' <<< "${data}")

echo "$mapped"
