#!/bin/bash

# Contains functions for creting "the tresure" and verifying it


set -euo pipefail

source ./utils.sh 

set -euo pipefail

# shellcheck disable=SC2120
place_treasure(){

    #|N| Modo        | Acción sobre el archivo elegido     | Valor devuelto                        |
    #|-| ----------- | ----------------------------------- | ------------------------------------- |
    #|0| `name`      | Nada                                | Nombre del archivo                    |
    #|1| `content`   | Nada                                | Contenido del archivo                 |
    #|2| `checksum`  | Nada                                | `sha256sum` o similar del archivo     |
    #|3| `encrypted` | Reencriptar con **otra passphrase** | Nueva passphrase usada                |
    #|4| `signed`    | Refirmar con **otra llave privada** | Nueva llave pública (`.pem`) generada |


    local mode=${1:-0}  # name by default

    # read file list 
    local files_list=()
    mapfile -t files_list < /tmp/files_path_list.txt

    # select a random file from the list
    local selected_file
    selected_file=${files_list[ $RANDOM % ${#files_list[@]} ]}
    echo "$selected_file" > /tmp/treasure_file_path.txt # save the selected file name to debug

    # process the selected file by mode
    case "$mode" in
        #name
        0)
            echo "$selected_file" # return file name
            ;;
        #content
        1)
            cat "$selected_file" # return file content
            ;;
        #checksum
        2)
            sha256sum "$selected_file" | awk '{print $1}'
            ;; # return checksum, but only the hash
        #encrypted
        3)  
            new_pass=$(openssl rand -hex 32) # cretae a new passphrase
            # encrypt the file with the new passphrase
            echo "$new_pass" | gpg --batch --yes --passphrase-fd 0 -c "$selected_file"
            echo "$new_pass" # return the new passphrase
            # remove original .txt files
            for file in "${files_list[@]}"; do
                    rm "$file"
            done
            ;;
        #signed
        4) 
            openssl genrsa -out private2.pem 2048
            openssl rsa -in private2.pem -pubout -out public2.pem
            openssl dgst -sha256 -sign private2.pem -out "$selected_file".sig "$selected_file"
      
            cat public2.pem
            rm private2.pem
            rm public2.pem
           
            ;;
        *)
            echo "Invalid mode: $mode" >&2
            return 1
            ;;
    esac
}

verify(){
    #| N | Modo        | Acción esperada                               |
    #| - | ----------- | --------------------------------------------- |
    #| 0 | `name`      | Comparar el **nombre del archivo**            |
    #| 1 | `content`   | Comparar el **contenido literal del archivo** | 
    #| 3 | `encrypted` | **Intentar desencriptar** con la passphrase   |
    #| 4 | `signed`    | Verificar firma con **llave pública**         | 

    local mode=${1:-0}
    local file_path=${2:-""}
    local treasure_key
    treasure_key=$(cat /tmp/treasure_key.txt)
    case "$mode" in
        #name
        0)
            if [ "$file_path" == "$treasure_key" ]; then
                echo "1"
            else
                echo "0"
            fi
            ;;
        #content
        1)
            if [ "$(cat "$file_path")" == "$treasure_key" ]; then
                echo "1"
            else
                echo "0"
            fi
            ;;
        #checksum
        2)
            if [ "$(sha256sum "$file_path" | awk '{print $1}')" == "$treasure_key" ]; then
                echo "1"
            else
                echo "0"
            fi
            ;;
        #encrypted
        3)
            if echo "$treasure_key" | gpg --batch --quiet --passphrase-fd 0 -d "$file_path" >/dev/null 2>&1; then
                echo "1"
            else
                echo "0"
            fi
            ;;
        #signed
        4)
            local public_key_path="/tmp/verify_public.pem"
            cat /tmp/treasure_key.txt > "$public_key_path"

            if openssl dgst -sha256 -verify "$public_key_path" -signature "$file_path.sig" "$file_path" >/dev/null 2>&1; then
                echo "1"
            else
                echo "0"
            fi
            ;;
        *)
            echo "Invalid mode: $mode" >&2
            return 1
            ;;
    esac
}

