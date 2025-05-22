#!/bin/bash

# Contains functions for creating directories and files for the game

set -euo pipefail

# shellcheck disable=SC2120

# create all the directories and files for the game
create_board(){
    local depth=${1:-3}
    local width=${2:-2}
    local files=${3:-4}
    local dir_base="dir_"

    local root_name
    root_name=$(cat /tmp/root_dir_name.txt)

    mkdir "$root_name" 
    local current_level_dirs=("$root_name")  # level 0

    for i in $(seq 1 "$depth"); do  # for each level
        local next_level_dirs=()
        
        for parent_dir in "${current_level_dirs[@]}"; do  # make directory

                for j in $(seq 1 "$width"); do
                    local dir_name="$dir_base$i$j"
                    mkdir "$parent_dir/$dir_name" && next_level_dirs+=("$parent_dir/$dir_name") # && echo "dir $parent_dir/$dir_name created"

                done    
            
        done
        current_level_dirs=("${next_level_dirs[@]}")
    done

    local file_counter=1
    declare -i file_counter
    local files_list=()
    # create files
    for parent_dir in "${current_level_dirs[@]}"; do 
        for _ in $(seq 1 "$files"); do
            local file_name="$parent_dir/file_$file_counter.txt"
            touch "$file_name"  && files_list+=("$file_name") 
            file_counter+=1
        done

    done
    
    # save list in /tmp/files_path_list.txt
    for file in "${files_list[@]}"; do
        echo "$file"
    done > /tmp/files_path_list.txt

}


# clean all the directories and files created for the game
clean_board(){
    local root_name
    root_name=$(cat /tmp/root_dir_name.txt)
    rm -rf "$root_name"
    rm -rf /tmp/files_path_list.txt
    rm -rf /tmp/treasure_key.txt
    rm -rf /tmp/treasure_file_path.txt
    rm -rf /tmp/verify_public.pem
    echo "all cleaned up! ;)" #success message
}





# fill all the files with the selected mode
    #| N | Mode        | File content                         | Post-processing    |
    #| - | ----------- | ------------------------------------ | ------------------ |
    #| 0 | `name`      | Free, can be empty                   | None               |
    #| 1 | `content`   | Must contain random characters       | None               |
    #| 2 | `checksum`  | Must contain random characters       | None               |
    #| 3 | `encrypted` | Free, not empty                      | Encrypt with GPG   |
    #| 4 | `signed`    | Free, not empty                      | Sign with OpenSSL  |

fill_board(){
    
    local mode=${1:-0}

    # read file list 
    local files_list=()
    mapfile -t files_list < /tmp/files_path_list.txt

    # write inside files if encrypted or signed mode first
    if [ "$mode" -eq 3 ] || [ "$mode" -eq 4 ]; then
        if [ ! -f gominola.txt ]; then
            echo "File gominola.txt not found"
            return 1
        fi

        for file in "${files_list[@]}"; do
            shuf -n 1 gominola.txt > "$file"
        done

    fi

    # write/postprocess inside files by mode
    case "$mode" in
    0)  for file in "${files_list[@]}"; do
            echo "abcd" > "$file"
        done ;;

    1|2)for file in "${files_list[@]}"; do
            openssl rand -base64 50 > "$file"
        done ;;

    3)  pass=$(openssl rand -hex 32)
        for file in "${files_list[@]}"; do
            echo "$pass" | gpg --batch --yes --passphrase-fd 0 -c "$file"
        done 
        ;;

    4)  local pvk_name="/tmp/.private.pem"
        local pubk_name="/tmp/.public.pem"

        # always create new keys
        openssl genrsa -out "$pvk_name" 2048
        openssl rsa -in "$pvk_name" -pubout -out "$pubk_name"
             
        # sign each file
        for file in "${files_list[@]}"; do
            openssl dgst -sha256 -sign "$pvk_name" -out "$file.sig" "$file"
        done 
        ;;

    *) echo "Invalid mode: $mode" ; return 1 ;;
    esac

}

