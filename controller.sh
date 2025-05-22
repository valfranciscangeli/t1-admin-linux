#!/bin/bash

# Contains functions for creting "the tresure" and verifying it


set -euo pipefail

# hide treasure in a random file, processing it according to the mode
#|N| Mode        | Action on the chosen file              | Returned value                     |
#|-| ----------- | -------------------------------------- | ---------------------------------- |
#|0| `name`      | Nothing                                | File name                          |
#|1| `content`   | Nothing                                | File content                       |
#|2| `checksum`  | Nothing                                | `sha256sum` or similar of the file |
#|3| `encrypted` | Re-encrypt with **another passphrase** | New passphrase used                |
#|4| `signed`    | Re-sign with **another private key**   | New public key (`.pem`) generated  |

place_treasure(){

    local mode=${1:-0}  # name by default

    # read file list 
    local files_list=()
    mapfile -t files_list < /tmp/files_path_list.txt

    # select a random file from the list
    local selected_file
    selected_file=${files_list[ $RANDOM % ${#files_list[@]} ]}
    echo "$selected_file" > /tmp/treasure_file_path.txt # save the selected file name to debug only

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
            new_pass=$(openssl rand -hex 32) # create a new passphrase
            rm "$selected_file" # remove the original file

            # create a new file with the same name
            touch "$selected_file"

            # fill the new file with a random line from gominola.txt
            if [ ! -f gominola.txt ]; then
                echo "File gominola.txt not found"
                return 1
            fi
            shuf -n 1 gominola.txt > "$selected_file"

            # encrypt the new file with the new passphrase
            echo "$new_pass" | gpg --batch --yes --passphrase-fd 0 -c "$selected_file"

            echo "$new_pass" # return the new passphrase
            ;;
        #signed
        4)  local pvk_name2="/tmp/.private2.pem"
            local pubk_name2="/tmp/.public2.pem"

            # create new keys
            openssl genrsa -out "$pvk_name2" 2048
            openssl rsa -in "$pvk_name2" -pubout -out "$pubk_name2"

            # fill the new file with a random line from gominola.txt
            if [ ! -f gominola.txt ]; then
                echo "File gominola.txt not found"
                return 1
            fi
            # replace the original file
            shuf -n 1 gominola.txt > "$selected_file"


            # sign the new file with the new private key
            openssl dgst -sha256 -sign "$pvk_name2" -out "$selected_file".sig "$selected_file"

            # return the public key
            cat $pubk_name2           
            ;;
        *)
            echo "Invalid mode: $mode" >&2
            return 1
            ;;
    esac
}


# verify if the candidate file is the treasure
#| N | Mode        | Expected Action                                   |
#| - | ----------- | ------------------------------------------------ |
#| 0 | `name`      | Compare the **file name**                        |
#| 1 | `content`   | Compare the **literal content of the file**      |
#| 2 | `checksum`  | Compare the **checksum (sha256sum) of the file** |
#| 3 | `encrypted` | **Try to decrypt** with the passphrase           |
#| 4 | `signed`    | Verify signature with **public key**             |

verify(){
   
    local mode=${1:-0} # name by default
    local file_path=${2:-""} # file path to verify

    local treasure_key # read the treasure key from the file
    treasure_key=$(cat /tmp/treasure_key.txt)
    case "$mode" in
        #name
        0)
            if [ "$file_path" == "$treasure_key" ]; then # compare file name
                echo "1"
            else
                echo "0"
            fi
            ;;
        #content
        1)
            if [ "$(cat "$file_path")" == "$treasure_key" ]; then #compare file content
                echo "1"
            else
                echo "0"
            fi
            ;;
        #checksum
        2)
            if [ "$(sha256sum "$file_path" | awk '{print $1}')" == "$treasure_key" ]; then #compare checksum
                echo "1"
            else
                echo "0"
            fi
            ;;
        #encrypted
        3)
            #check if the file can be decrypted with the passphrase saved in the treasure key
            if echo "$treasure_key" | gpg --batch --quiet --passphrase-fd 0 -d "$file_path" >/dev/null 2>&1; then 
                echo "1"
            else
                echo "0"
            fi
            ;;
        #signed
        4)
            # create a temporary public key file
            local public_key_path="/tmp/verify_public.pem"
            cat /tmp/treasure_key.txt > "$public_key_path"

            # verify the signature with the public key
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

