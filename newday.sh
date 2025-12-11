#!/bin/bash
set -euo pipefail

latest_day=$(ls -d day[0-9][0-9] 2>/dev/null | sed 's/day0*//' | sort -n | tail -1)
next_day=$(( ${latest_day:-0} + 1 ))

padded_day=$(printf "%02d" $next_day)
dest_dir="day${padded_day}"

if [ ! -d "template" ]; then
  exit 1
fi

if [ -d "$dest_dir" ]; then
  exit 1
fi

cp -r "template" "${dest_dir}"

for f in "${dest_dir}/v.mod" "${dest_dir}/.gitignore"; do
  if [ -f "$f" ]; then
    sed -i "s/<<day0>>/${padded_day}/g" "$f"
    sed -i "s/<<day>>/${next_day}/g" "$f"
  fi
done
