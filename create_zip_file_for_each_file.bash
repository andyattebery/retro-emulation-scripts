#!/usr/bin/env bash

ext=$1

for file in *.$ext; do
  if [[ -f "$file" ]]; then
    filename="${file%.*}"
    echo $filename
    zip "${filename}.zip" "$file"
  fi
done