#!/usr/bin/env bash
# PostToolUse (Write|Edit) hook: validate an edited _data/*.yml file so a YAML
# typo can't silently break the Jekyll / GitHub Pages build.
#
# Reads the hook JSON on stdin, extracts tool_input.file_path, and — only when
# the edited file is under _data/ — parses it. Exit 2 with feedback on invalid
# YAML; exit 0 otherwise. If no YAML parser is available it skips silently, so
# it can never report a false positive.

f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)

case "$f" in
  */_data/*.yml|*/_data/*.yaml) ;;
  *) exit 0 ;;
esac
[ -f "$f" ] || exit 0

if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' 2>/dev/null; then
  err=$(python3 -c '
import sys, yaml
try:
    yaml.safe_load(open(sys.argv[1]))
except Exception as e:
    sys.exit(str(e))
' "$f" 2>&1) || {
    printf '%s\n' "Invalid YAML in $f (fix before it breaks the GitHub Pages / Jekyll build):" "$err" >&2
    exit 2
  }
elif command -v ruby >/dev/null 2>&1; then
  err=$(ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$f" 2>&1) || {
    printf '%s\n' "Invalid YAML in $f (fix before it breaks the GitHub Pages / Jekyll build):" "$err" >&2
    exit 2
  }
fi

exit 0
