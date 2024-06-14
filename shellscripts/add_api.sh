#!/bin/bash
# title: add_api
# date created: "2023-02-04"

# Read the API title and API key from the command line arguments
API_TITLE="$1"
API_KEY="$2"

# Define the path to the API directory
API_DIR="$HOME/API"

# Create the API directory if it doesn't exist
mkdir -p "$API_DIR"

# Create the API file with the specified title
API_FILE="$API_DIR/$API_TITLE"
touch "$API_FILE"

# Add the export statement with the API title and API key to the API file
echo "export $API_TITLE='$API_KEY'" >> "$API_FILE"

# Confirm that the API file has been created and the API key has been added
echo "API file created at $API_FILE with API key $API_KEY"

for file in ~/API/*; do
  source $file
done

exit 0


