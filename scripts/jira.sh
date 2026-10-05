#!/usr/bin/env bash
# Tiny Jira Cloud helper used by the GitHub workflows.
# Needs env: JIRA_BASE_URL (https://yourco.atlassian.net), JIRA_EMAIL, JIRA_API_TOKEN
#
# Usage:
#   jira.sh fetch       KEY            -> ticket (summary, description, comments) as markdown
#   jira.sh summary     KEY            -> ticket summary (one line)
#   jira.sh latest-plan KEY            -> body of the latest "[AI-PLAN]" comment
#   jira.sh comment     KEY FILE       -> add FILE's content as a comment
#   jira.sh transition  KEY "Name"     -> move ticket using the transition called "Name"
set -euo pipefail

: "${JIRA_BASE_URL:?JIRA_BASE_URL not set}"
: "${JIRA_EMAIL:?JIRA_EMAIL not set}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN not set}"

BASE="${JIRA_BASE_URL%/}/rest/api/2"

api() {
  curl -sS --fail-with-body \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$@"
}

cmd="${1:?command required}"
key="${2:?issue key required}"

case "$cmd" in
  fetch)
    api "$BASE/issue/$key?fields=summary,description,issuetype,priority,labels,comment" | jq -r '
      "# \(.key): \(.fields.summary)\n" +
      "Type: \(.fields.issuetype.name) | Priority: \(.fields.priority.name // "n/a") | Labels: \((.fields.labels // []) | join(", "))\n\n" +
      "## Description\n\(.fields.description // "(no description)")\n\n" +
      "## Comments (oldest first)\n" +
      ([.fields.comment.comments[] | "### \(.author.displayName) — \(.created)\n\(.body)\n"] | join("\n"))'
    ;;

  summary)
    api "$BASE/issue/$key?fields=summary" | jq -r '.fields.summary'
    ;;

  latest-plan)
    api "$BASE/issue/$key/comment?orderBy=created&maxResults=100" | jq -r '
      [.comments[] | select(.body | startswith("[AI-PLAN]"))] | last | .body // empty'
    ;;

  comment)
    file="${3:?file required}"
    # Jira comments max out around 32k chars; keep a safety margin.
    jq -n --rawfile b "$file" '{body: ($b[0:30000])}' \
      | api -X POST "$BASE/issue/$key/comment" -d @- > /dev/null
    echo "Commented on $key"
    ;;

  transition)
    name="${3:?transition name required}"
    # Match the transition name OR its target status name, case-insensitively,
    # so "In review", "In Review" and "Move to In review" all work.
    id="$(api "$BASE/issue/$key/transitions" \
      | jq -r --arg n "$name" '
          ($n | ascii_downcase) as $want
          | .transitions[]
          | select((.name | ascii_downcase) == $want or (.to.name | ascii_downcase) == $want)
          | .id' | head -n1)"
    if [[ -z "$id" ]]; then
      echo "WARN: transition '$name' not available for $key (check your Jira workflow). Skipping." >&2
      exit 0
    fi
    api -X POST "$BASE/issue/$key/transitions" -d "{\"transition\":{\"id\":\"$id\"}}" > /dev/null
    echo "Moved $key via '$name'"
    ;;

  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
