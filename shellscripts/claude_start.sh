#!/bin/bash

# Prompt for project name
read -p "Enter your project name: " project_name

read -p "What components would you like to install (space delimited, enter for none)? " components

# Create Vite React project
npm create vite@latest $project_name -- --template react

cd $project_name

npm install
# Install Tailwind CSS and its dependencies
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Base URL for raw content
BASE_URL="https://raw.githubusercontent.com/mattppal/shadcn-ui-vite-react/main"

# Check if curl is installed
if ! command -v curl &>/dev/null; then
  echo "Error: curl is not installed. Please install curl and try again."
  exit 1
fi

# List of files to download
FILES=(
  "src/App.jsx"
  "public/vite.svg"
  "public/react.svg"
  "public/shadcn-ui.svg"
  "components.json"
  "jsconfig.json"
  "vite.config.js"
)

# Function to download a file
download_file() {
  local remote_path="$1"
  local local_path="$2"
  local url="$BASE_URL/$remote_path"

  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$local_path")"

  if curl -sSf "$url" -o "$local_path"; then
    echo "Successfully downloaded: $remote_path"
  else
    echo "Failed to download: $remote_path"
  fi
}

# Check if curl is installed
if ! command -v curl &>/dev/null; then
  echo "Error: curl is not installed. Please install curl and try again."
  exit 1
fi

# Download each file
for file in "${FILES[@]}"; do
  download_file "$file" "$file"
done

echo "Download process completed."

# Function to process each component
process_component() {
  local component=$1
  echo "Processing component: $component"
  # Replace the following line with your desired command
  npx shadcn-ui@latest add $component
}

# Default components
default_components=("card" "button")

# Check if components variable is set
if [ -z "${components}" ]; then
  # If not set, use only default components
  component_array=("${default_components[@]}")
else
  # Convert the space-separated string to an array
  IFS=' ' read -ra user_components <<<"$components"

  # Combine default and user components, removing duplicates
  component_array=()
  for component in "${default_components[@]}" "${user_components[@]}"; do
    # Convert to lowercase for case-insensitive comparison
    component_lower=$(echo "$component" | tr '[:upper:]' '[:lower:]')
    # Check if component is already in the array
    if [[ ! " ${component_array[*]} " =~ " ${component_lower} " ]]; then
      component_array+=("$component_lower")
    fi
  done
fi

# Check if the array is empty (this should never happen due to defaults, but just in case)
if [ ${#component_array[@]} -eq 0 ]; then
  echo "Component list is empty. This shouldn't happen. Exiting."
  exit 1
fi

# Loop through all components
for component in "${component_array[@]}"; do
  process_component "$component"
done

# npx shadcn-ui@latest init -y -d

npm run dev
Click to switch to the original text.Click to Translate Page.SettingsPDF Translate
