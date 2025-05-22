#!/bin/bash

set -euo pipefail

source ./board.sh  
source ./controller.sh  


init_game(){
    echo "./board_root" > /tmp/root_dir_name.txt
    clean_board

    echo "Hi! are you ready to play the greatest game of all times? [y/n]"
    read -r proceed
    if [ "$proceed" == "y" ]; then
        echo "ok"
         create_board
        fill_board
        place_tresure
        local attempts=5
        echo "look for the treasure inside $(cat /tmp/root_dir_name.txt)"
        while [ $attempts -gt 0 ]; do
            echo "you have $attempts attempts left"
            echo "enter the path of the candidate file:"
            read -r file_path
            local is_found
            is_found=$(verify "$file_path")
            if [ "$is_found" -eq 1 ]; then
                echo "you found the treasure!"
                break
            else
                echo "this is not the treasure"
                attempts=$((attempts - 1))
                if [ $attempts -eq 0 ]; then
                    echo "you lost! the treasure was in $(cat /tmp/treasure_path.txt)"
                    break
                fi
                echo "want to try again? [y/n]"
                read -r try_again
                if [ "$try_again" == "n" ]; then
                    echo "the biggest loser is the one who gives up... bye!"
                    clean_board
                    exit
                fi
                echo "ok, let's try again"
                
            fi
        done
        echo "treasure in $(place_tresure)"
    else 
        echo "sad to see you go, but ok. bye!" 
        exit
    fi
   
}

init_game