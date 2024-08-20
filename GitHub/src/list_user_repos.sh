#!/bin/zsh

source ./.env

echo "Requesting repositories for user: ${gh_user}" >&2

response=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${gh_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/users/${gh_user}/repos"
)

echo "Finished request" >&2

echo "$response"