#!/usr/bin/env bash
set -euo pipefail

: "${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}"

# Helper: detect GNU vs BSD date
if date --version >/dev/null 2>&1; then
  # GNU date
  to_ts() { date -d "$1" +%s; }
  to_human() { date -d "$1" +"%b %d, %Y"; }
else
  # BSD date (macOS)
  to_ts() {
    # strip .000Z (or .XYZZ) and trailing Z
    local s="${1%%.*}"
    s="${s%Z}"
    date -j -f "%Y-%m-%dT%H:%M:%S" "$s" +%s
  }
  to_human() {
    local s="${1%%.*}"
    s="${s%Z}"
    date -j -f "%Y-%m-%dT%H:%M:%S" "$s" +"%b %d, %Y"
  }
fi

# Fetch all orgs
orgs=$(curl -s \
  -H "Authorization: Key $GREMLIN_API_KEY" \
  -H "Accept: application/json" \
  https://api.gremlin.com/v1/orgs)

now_ts=$(date +%s)
threshold=$((30 * 86400))

printf '\n%-30s %-15s %s\n' "Team" "Expiry Date" "Days Left"
printf '%-30s %-15s %s\n' "----" "-----------" "---------"

fail=0

echo "$orgs" \
  | jq -r '.[] | "\(.name)\t\(.certificate_expires_on)"' \
  | while IFS=$'\t' read -r name exp; do
      ts=$(to_ts "$exp")
      days=$(( (ts - now_ts) / 86400 ))
      human=$(to_human "$exp")

      if (( days < 30 )); then
        # red
        printf '\e[31m%-30s %-15s %3d days\e[0m\n' "$name" "$human" "$days"
        fail=1
      else
        # green
        printf '\e[32m%-30s %-15s %3d days\e[0m\n' "$name" "$human" "$days"
      fi
    done

if (( fail )); then
  echo -e "\n\033[1;31mError: one or more certificates expire in < 30 days!\033[0m"
  exit 1
else
  echo -e "\n\033[1;32mAll certificates are valid for at least 30 days.\033[0m"
  exit 0
fi

