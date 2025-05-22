#!/bin/bash

set -euo pipefail

source ./board.sh  
source ./controller.sh  


init_game(){

    echo "./board_root" > /tmp/root_dir_name.txt

    clean_board # clear previous games data


    echo "Hi! are you ready to play the greatest game of all times? [y/n]"
    read -r proceed
    if [ "$proceed" == "y" ]; then
        echo "ok, let's start!"
        echo "how many levels do you want to create? [1+]"
        read -r depth
        if ! [[ "$depth" =~ ^[0-9]+$ ]] || [[ "$depth" -lt 1 ]]; then
    echo "Error: 'depth' debe ser un número mayor a 0."
    exit 1
fi
        echo "how many directories do you want to create in each level? [1+]"
        read -r width
        if ! [[ "$width" =~ ^[0-9]+$ ]] || [[ "$width" -lt 1 ]]; then
    echo "Error: 'width' debe ser un número mayor a 0."
    exit 1
fi
        echo "how many files do you want to create in each directory? [1+]"
        read -r files
       if ! [[ "$files" =~ ^[0-9]+$ ]] || [[ "$files" -lt 1 ]]; then
    echo "Error: 'files' debe ser un número mayor a 0."
    exit 1
fi
        echo "ok, let's create the board with $depth levels, $width directories and $files files in each directory"
        echo "the directories will be named dir_xy, where x is the level and y is the directory number"
        echo "the files will be named file_1.txt, file_2.txt, etc."
        create_board "$depth" "$width" "$files"
        echo "the board has been created!"
        echo "the files are located in $(cat /tmp/root_dir_name.txt)"
        while true; do
            echo "which mode do you want to use to hide the treasure? [0-4]"
        echo "0: name"
        echo "1: content"
        echo "2: checksum"
        echo "3: encrypted"
        echo "4: signed"
        read -r mode
          case "$mode" in
            0)
                echo "you chose mode 0: name"
                ;;
            1)
                echo "you chose mode 1: content"
                ;;
            2)
                echo "you chose mode 2: checksum"
                ;;
            3)
                echo "you chose mode 3: encrypted"
                ;;
            4)
                echo "you chose mode 4: signed"
                ;;
            *)
                echo "invalid input, please enter a number between 0 and 4"
                exit 1
                ;;
        esac
         if [[ "$mode" =~ ^[0-4]$ ]]; then
            break
         fi
        done       
      
        fill_board "$mode"
        echo "the treasure has been hidden!"
        echo "now it's time to find it!"
        place_treasure "$mode" > /tmp/treasure_key.txt
        echo "look for the treasure inside $(cat /tmp/root_dir_name.txt)"
        while true; do
            echo "enter the path (./board_root/...) of the candidate file:"
            read -r file_path
            local is_found
            is_found=$(verify "$mode" "$file_path")
            if [ "$is_found" -eq 1 ]; then
                echo "you found the treasure!"
                break
            else
                echo "this is not the treasure :c"
                echo "want to try again? [y/n]"
                read -r try_again
                if [ "$try_again" == "n" ]; then
                    echo "the biggest loser is the one who gives up..."
                    echo "the treasure was hidden in $(cat /tmp/treasure_file_path.txt)"
                    echo "goodbye!"
                    clean_board
                    exit 0
                   
                fi
                echo "ok, let's try again"
            fi
        done
    else 
        echo "sad to see you go, but ok. bye!" 
        clean_board
        exit 0
    
    fi
    
   
}

init_game