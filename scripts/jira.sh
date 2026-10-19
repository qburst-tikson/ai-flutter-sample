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
#   jira.sh attachments KEY DIR        -> download image attachments (design screenshots) into DIR
set -euo pipefail

: "${JIRA_BASE_URL:?JIRA_BASE_URL not set}"
: "${JIRA_EMAIL:?JIRA_EMAIL not set}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN not set}"

BASE="${JIRA_BASE_URL%/}/rest/api/2"

api() {
  # Prints the body on success. On an HTTP error, prints the status and Jira's
  # message to stderr (and as a GitHub annotation) and exits non-zero.
  local tmp code
  tmp="$(mktemp)"
  code="$(curl -sS -o "$tmp" -w '%{http_code}' \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$@")" || { echo "::error title=Jira request failed::curl could not reach Jira (${JIRA_BASE_URL})" >&2; rm -f "$tmp"; exit 1; }
  if [[ "$code" -lt 200 || "$code" -ge 300 ]]; then
    local msg
    msg="$(jq -r '[(.errorMessages // [])[], ((.errors // {}) | to_entries[] | "\(.key): \(.value)")] | join("; ")' "$tmp" 2>/dev/null)"
    [[ -n "$msg" ]] || msg="$(head -c 300 "$tmp")"
    echo "::error title=Jira HTTP $code::$msg" >&2
    rm -f "$tmp"
    exit 1
  fi
  cat "$tmp"
  rm -f "$tmp"
}

cmd="${1:?command required}"
key="${2:?issue key required}"

case "$cmd" in
  fetch)
    json="$(api "$BASE/issue/$key?fields=summary,description,issuetype,priority,labels,comment")"
    jq -r '
      def txt: if . == null then "" elif type == "string" then . else tojson end;
      "# \(.key): \(.fields.summary)\n" +
      "Type: \(.fields.issuetype.name // "n/a") | Priority: \(.fields.priority.name // "n/a") | Labels: \((.fields.labels // []) | join(", "))\n\n" +
      "## Description\n\((.fields.description | txt) as $d | if $d == "" then "(no description)" else $d end)\n\n" +
      "## Comments (oldest first)\n" +
      ([(.fields.comment.comments // [])[] | "### \(.author.displayName // "unknown") — \(.created)\n\(.body | txt)\n"] | join("\n"))' <<<"$json"
    ;;

  summary)
    api "$BASE/issue/$key?fields=summary" | jq -r '.fields.summary'
    ;;

  latest-plan)
    api "$BASE/issue/$key/comment?orderBy=created&maxResults=100" | jq -r '
      [(.comments // [])[] | select((.body | type) == "string" and (.body | startswith("[AI-PLAN]")))] | last | .body // empty'
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

  attachments)
    # Downloads image attachments (design screenshots) into DIR and lists them in DIR/index.md.
    dir="${3:?directory required}"
    mkdir -p "$dir"
    max_files=8
    max_bytes=$((10 * 1024 * 1024))
    list="$(api "$BASE/issue/$key?fields=attachment" | jq -c --argjson max "$max_bytes" '
      [(.fields.attachment // [])[]
        | select((.mimeType // "") | test("^image/(png|jpe?g|webp|gif)$"))
        | select((.size // 0) <= $max)]
      | sort_by(.created) | .[]')"
    n=0
    : > "$dir/index.md"
    while IFS= read -r a; do
      [[ -n "$a" ]] || continue
      [[ $n -lt $max_files ]] || { echo "WARN: more than $max_files images on $key; extra ones skipped." >&2; break; }
      id="$(jq -r .id <<<"$a")"
      name="$(jq -r .filename <<<"$a" | tr -c 'A-Za-z0-9._-' '_')"
      url="$(jq -r .content <<<"$a")"
      out="$dir/${id}_${name}"
      if curl -fsSL -u "$JIRA_EMAIL:$JIRA_API_TOKEN" -o "$out" "$url"; then
        echo "- \`$out\` — $(jq -r '.filename + " (" + .mimeType + ", added " + (.created[0:10]) + ")"' <<<"$a")" >> "$dir/index.md"
        n=$((n + 1))
      else
        echo "WARN: could not download attachment $id ($name)." >&2
      fi
    done <<<"$list"
    echo "Downloaded $n image attachment(s) from $key into $dir" >&2
    ;;

  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
