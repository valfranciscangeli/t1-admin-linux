#!/bin/bash

source ./utils.sh 

set -euo pipefail

# shellcheck disable=SC2120
place_tresure(){

    #|N| Modo        | Acción sobre el archivo elegido     | Valor devuelto                        |
    #|-| ----------- | ----------------------------------- | ------------------------------------- |
    #|0| `name`      | Nada                                | Nombre del archivo                    |
    #|1| `content`   | Nada                                | Contenido del archivo                 |
    #|2| `checksum`  | Nada                                | `sha256sum` o similar del archivo     |
    #|3| `encrypted` | Reencriptar con **otra passphrase** | Nueva passphrase usada                |
    #|4| `signed`    | Refirmar con **otra llave privada** | Nueva llave pública (`.pem`) generada |


    local mode=${1:-0}

    #generate_files_list "$root_name"

    # read file list 
    local files_list=()
    mapfile -t files_list < /tmp/files_path_list.txt

    local selected_file=${files_list[ $RANDOM % ${#files_list[@]} ]}
    echo "$selected_file" > /tmp/treasure_path.txt

    case "$mode" in
        #name
        0)
            echo "$selected_file"
            ;;
        #content
        1)
            cat "$selected_file"
            ;;
        #checksum
        2)
            sha256sum "$selected_file" | awk '{print $1}'
            ;;
        #encrypted
        3) new_pass=$(openssl rand -hex 8)
            gpg --batch --yes --passphrase "$new_pass" -c "$selected_file"
            # rm "$selected_file"
            echo "$new_pass"
            ;;
        #signed
        4) openssl genrsa -out private2.pem 2048
        openssl rsa -in private2.pem -pubout -out public2.pem
        openssl dgst -sha256 -sign private2.pem -out "$selected_file".sig "$selected_file"
        cat public2.pem
            ;;
        *)
            echo "Invalid mode: $mode" >&2
            return 1
            ;;
    esac
}

verify(){
    echo "verify"
}
