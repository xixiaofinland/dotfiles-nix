#!/bin/bash
curl -s https://zenquotes.io/api/random | jq -r '.[0] | "\(.q) - \(.a)"'

