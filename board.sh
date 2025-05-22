#!/bin/bash

# Contains functions for creating directories and files for the game

set -euo pipefail

# shellcheck disable=SC2120
create_board(){
    local depth=${1:-3}
    local width=${1:-2}
    local files=${1:-4}
    local dir_base="dir_"

    local root_name
    root_name=$(cat /tmp/root_dir_name.txt)

    mkdir "$root_name" #&& echo "root dir created with name $root_name"
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
            touch "$file_name"  && files_list+=("$file_name") #&& echo "$file_name created"
            file_counter+=1
        done

    done
    
    # save list in /tmp/archivos.txt
    for file in "${files_list[@]}"; do
        echo "$file"
    done > /tmp/files_path_list.txt

}



clean_board(){
    local root_name
    root_name=$(cat /tmp/root_dir_name.txt)
    rm -rf "$root_name"
    rm -rf /tmp/root_dir_name.txt
    rm -rf /tmp/treasure_path.txt
    rm -rf /tmp/files_path_list.txt
    echo "all cleaned up! ;)"
}



# shellcheck disable=SC2120
fill_board(){
    #| # | Modo        | Contenido del archivo                | Postprocesamiento  |
    #| - | ----------- | ------------------------------------ | ------------------ |
    #| 0 | `name`      | Libre, pueden estar vacíos           | Ninguno            |
    #| 1 | `content`   | Deben contener caracteres aleatorios | Ninguno            |
    #| 2 | `checksum`  | Deben contener caracteres aleatorios | Ninguno            |
    #| 3 | `encrypted` | Libre, no vacíos                     | Encriptar con GPG  |
    #| 4 | `signed`    | Libre, no vacíos                     | Firmar con OpenSSL |

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

    3)  pass=$(openssl rand -hex 8)
        for file in "${files_list[@]}"; do
            gpg --batch --yes --passphrase "$pass" -c "$file"
            # rm "$file"
        done ;;

    4)  if [ ! -f private.pem ]; then
            openssl genrsa -out private.pem 2048
            openssl rsa -in private.pem -pubout -out public.pem
        fi

        for file in "${files_list[@]}"; do
            openssl dgst -sha256 -sign private.pem -out "$file".sig "$file"
            # rm "$file"
        done ;;

    *) echo "Invalid mode: $mode" ; return 1 ;;
    esac

}

