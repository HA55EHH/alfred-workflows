#!/bin/bash

# Check if the environment variable is set
if [ -z "$alfred_workflow_cache" ]; then
  echo "Environment variable alfred_workflow_cache is not set."
  exit 1
fi

# Remove everything inside the directory
rm -rf "${alfred_workflow_cache:?}/"*

echo "All files in $alfred_workflow_cache have been removed."