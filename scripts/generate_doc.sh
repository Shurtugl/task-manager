#!/bin/bash
set -e
export LC_ALL=C.UTF-8

DOCS_DIR="docs"
FRONTEND_DIR="frontend"
BACKEND_DIR="backend"

mkdir -p "$DOCS_DIR"

generate_md () {
  local src_dir=$1
  local out_file=$2
  echo "# ${src_dir^}" > "$out_file"

  find "$src_dir" -type f | while read -r file; do
    ext="${file##*.}"
    echo "## $file" >> "$out_file"
    echo '```'"$ext" >> "$out_file"
    iconv -f UTF-8 -t UTF-8 -c "$file" | sed 's/```/`​`​`/g' >> "$out_file"
    echo '```' >> "$out_file"
  done
}

generate_md "$FRONTEND_DIR" "$DOCS_DIR/frontend.md"
generate_md "$BACKEND_DIR" "$DOCS_DIR/backend.md"
