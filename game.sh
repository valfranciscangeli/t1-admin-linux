#!/bin/bash

set -euo pipefail

# import modules
source ./board.sh  
source ./controller.sh

# colors for terminal text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# function for print section headers
header() {
    echo -e "${CYAN}"
    echo "===================================="
    echo "   $1"
    echo "===================================="
    echo -e "${NC}"
}

# for showing success messages
success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

# for showing error messages
error() {
    echo -e "${RED}[✗] $1${NC}"
}

# for showing info messages
info() {
    echo -e "${BLUE}[i] $1${NC}"
}

# for showing warning messages
warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# main function to initialize the game
init_game() {
    clear #clear the terminal
    echo "./board_root" > /tmp/root_dir_name.txt # save the root directory name
    clean_board >/dev/null # clear previous games data
 
    # Show welcome message
    header "TREASURE HUNT GAME"
    
    info "Hi! Are you ready to play the greatest game of all times? [y/n]"
    read -r proceed
    
    if [ "$proceed" != "y" ]; then
        warning "Sad to see you go, but ok. Bye!" 
        clean_board
        exit 0
    fi

    success "Ok, let's start!"
    
    # board configuration
    header "BOARD CONFIGURATION"
    while true; do
        read -p "How many levels do you want to create? [1+] " depth
        if [[ "$depth" =~ ^[0-9]+$ ]] && [[ "$depth" -gt 0 ]]; then
            break
        else
            error "Error: 'depth' must be a number greater than 0."
        fi
    done

    while true; do
        read -p "How many directories per level? [1+] " width
        if [[ "$width" =~ ^[0-9]+$ ]] && [[ "$width" -gt 0 ]]; then
            break
        else
            error "Error: 'width' must be a number greater than 0."
        fi
    done

    while true; do
        read -p "How many files per directory? [1+] " files
        if [[ "$files" =~ ^[0-9]+$ ]] && [[ "$files" -gt 0 ]]; then
            break
        else
            error "Error: 'files' must be a number greater than 0."
        fi
    done

    # we only continue if all parameters are valid

    # show summary of the board configuration
    info "Creating board with:"
    echo -e "• Levels: ${YELLOW}$depth${NC}"
    echo -e "• Directories per level: ${YELLOW}$width${NC}"
    echo -e "• Files per directory: ${YELLOW}$files${NC}"
    echo -e "• Directories will be named ${YELLOW}dir_xy${NC}"
    echo -e "• Files will be named ${YELLOW}file_N.txt${NC}"
    
    # call for creating the board
    info "Creating board..."
    create_board "$depth" "$width" "$files"
    success "Board created successfully!"
    info "Files are located in: $(cat /tmp/root_dir_name.txt)"

    # select game mode
    header "GAME MODE SELECTION"
    echo -e "Choose how to hide the treasure:"
    echo -e "${YELLOW}0${NC}: Name"
    echo -e "${YELLOW}1${NC}: Content"
    echo -e "${YELLOW}2${NC}: Checksum"
    echo -e "${YELLOW}3${NC}: Encrypted"
    echo -e "${YELLOW}4${NC}: Signed"
    
    while true; do
        read -p "Select mode [0-4]: " mode
        case "$mode" in
            0) success "You chose: Name mode"; break ;;
            1) success "You chose: Content mode"; break ;;
            2) success "You chose: Checksum mode"; break ;;
            3) success "You chose: Encrypted mode"; break ;;
            4) success "You chose: Signed mode"; break ;;
            *) error "Invalid option, please enter 0-4" ;;
        esac
    done

    # we only continue if the mode is valid
    
    info "Filling all files..."
    fill_board "$mode"
    
    info "Hiding the treasure..."
    clue=$(place_treasure "$mode" | tee /tmp/treasure_key.txt)
    success "The treasure has been hidden!"
    if [ "$mode" -eq 0 ]; then
        clue="$(basename "$clue")"
    fi
    info "This is the clue: $clue. Good luck!"

    # game start
    header "TREASURE HUNT BEGINS!"
    info "Look for the treasure inside $(cat /tmp/root_dir_name.txt) folder ..."
    
    # main game loop
    while true; do
        read -p "Enter the full path (./board_root/...) [or n for exit]: " file_path
        
        # check if the user wants to exit
        if [ "$file_path" == "n" ]; then
            error "The biggest loser, is the one who gives up..."
            warning "The treasure was hidden in: $(cat /tmp/treasure_file_path.txt)"
            clean_board >/dev/null
            info "Goodbye!"
            exit 0
        fi
        local is_found
        is_found=$(verify "$mode" "$file_path")

        # hunt is successful
        if [ "$is_found" -eq 1 ]; then
            echo -e "\n${GREEN}"
            echo "===================================="
            echo "   CONGRATULATIONS! YOU FOUND IT!"
            echo "===================================="
            echo -e "${NC}"
            break
        # hunt is unsuccessful
        else
            error "This is not the treasure :c"
            warning "Remember, the clue is: $clue"
        fi
    done
    
    clean_board > /dev/null
    exit 0
}

init_game