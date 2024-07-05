#!/bin/bash

FILE_URL="https://raw.githubusercontent.com/forcedotcom/salesforcedx-vscode/develop/packages/salesforcedx-vscode-apex/out/apex-jorje-lsp.jar"

SAVE_PATH="$HOME/apex-jorje-lsp.jar"

LAST_MODIFIED_FILE=".apex_lsp_etag" # Etag also defines the resource version as "last modified date" doesn't present in the response

get_last_modified() {
    curl -sI "$FILE_URL" | grep -i "ETag" | awk '{print $2}'
}

download_file() {
    curl -L -o "$SAVE_PATH" "$FILE_URL"
}

# Get the current Last-Modified date
current_modified=$(get_last_modified)

if [ -f "$LAST_MODIFIED_FILE" ]; then
    last_modified=$(cat "$LAST_MODIFIED_FILE")
else
    last_modified=""
fi

if [ "$current_modified" != "$last_modified" ]; then
    echo -e "apex-jorje-lsp.jar has been updated in github. Downloading new version...\n"
    download_file
    echo "$current_modified" > "$LAST_MODIFIED_FILE"
else
    echo "apex-jorje-lsp.jar no change detected."
fi
