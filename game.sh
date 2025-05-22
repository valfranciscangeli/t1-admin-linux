#!/bin/bash

set -euo pipefail

source ./board.sh  
source ./controller.sh  


init_game(){
    echo "./board_root" > /tmp/root_dir_name.txt
    clean_board

    echo "Hi! are you ready to play the best game of your life? [y/n]"
    read -r proceed
    if [ "$proceed" == "y" ]; then
        echo "ok"
         create_board
        fill_board
        echo "treasure in $(place_tresure)"
    else 
        echo "bye!" 
        exit
    fi
   
}

init_game