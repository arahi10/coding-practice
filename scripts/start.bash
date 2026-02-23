#!/usr/bin/bash
set -eo pipefail

main() {
  read -p "title?: " -r raw_title
  read -p "url?: " -r url
  name="${raw_title//[[:space:]]/_}"
  cp -r templates "$name"
  local doc="$name"/memo.md
  sed -i "s/Problem TitLe/$raw_title/g" "$doc"
  sed -i "s|Problem Link|<$url>|g" "$doc"
  git fetch origin
  git switch -c "$name" main
  code "$doc"
}
main
