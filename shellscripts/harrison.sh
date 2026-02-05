#!/bin/bash
# title: harrison
# date created: "2023-08-11"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./shellscripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 'search term'"
    exit 1
fi
searchTerm="$1"
encodedSearchTerm=$(echo $searchTerm | sed 's/ /%20/g')
url="https://accesspharmacy-mhmedical-com.autorpa.kfsyscc.org/searchresults.aspx?q=$encodedSearchTerm&f_BookID=3095&adv=True&bookSearch=True"
open_cmd "$url"

exit 0
