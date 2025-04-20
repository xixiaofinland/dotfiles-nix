#!/bin/bash

# 1. daily quote

curl -s https://zenquotes.io/api/random | jq -r '.[0] | "\(.q) - \(.a)"' > "$HOME/.quote"

# 2. Apex LSP update

FILE_URL="https://raw.githubusercontent.com/forcedotcom/salesforcedx-vscode/develop/packages/salesforcedx-vscode-apex/out/apex-jorje-lsp.jar"

SAVE_PATH="$HOME/apex-jorje-lsp.jar"

LAST_MODIFIED_FILE="$HOME/.apex_lsp_etag" # Etag also defines the resource version as "last modified date" doesn't present in the response

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

echo -e "-- Check jorje..."
NC='\033[0m' # No Color
if [ "$current_modified" != "$last_modified" ]; then
    RED='\033[0;31m'
    echo -e "${RED}apex-jorje-lsp.jar: downloading new version...${NC}\n"
    download_file
    echo "$current_modified" > "$LAST_MODIFIED_FILE"
else
    GREEN='\033[0;32m'
    echo -e "${GREEN}apex-jorje-lsp.jar: no change detected.${NC}\n"
fi

# 3. repos pull

echo -e "-- Pull dotfiles..."
git -C $HOME/dotfiles-nix/ pull

# echo -e "\n-- Updating afmt repository with jj..."
# (
#     cd "$HOME/projects/afmt/" || exit 1
#     jj git fetch;jj rebase -s main -d main@origin;jj bto
# )
