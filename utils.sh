#!/bin/bash

files_list=()

generate_files_list() {
    local root_dir="$1"
    files_list=()
    _collect_files "$root_dir"
}

_collect_files() {
    local curr_dir="$1"

    for file in "$curr_dir"/*; do
        [ -e "$file" ] || continue # if file exists

        if [ -d "$file" ]; then # if its a directory
            _collect_files "$file"  # recursive call
        elif [ -f "$file" ]; then # if its a file
            files_list+=("$file") # add to list
        fi
    done
}
