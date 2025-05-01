#!/usr/bin/env bash
set -e

: "${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}"

curl -s -H "Authorization: Key $GREMLIN_API_KEY" \
     -H "Accept: application/json" \
     https://api.gremlin.com/v1/orgs \
| jq -r '.[] | "\(.name): expires on \(.certificate_expires_on)"'

