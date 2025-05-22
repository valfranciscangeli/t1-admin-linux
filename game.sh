#!/bin/bash

set -euo pipefail

# Importar módulos
source ./board.sh  
source ./controller.sh

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar encabezados
header() {
    echo -e "${CYAN}"
    echo "===================================="
    echo "   $1"
    echo "===================================="
    echo -e "${NC}"
}

# Función para mensajes de éxito
success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

# Función para mensajes de error
error() {
    echo -e "${RED}[✗] $1${NC}"
}

# Función para mensajes informativos
info() {
    echo -e "${BLUE}[i] $1${NC}"
}

# Función para advertencias
warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

init_game() {
    clear
    echo "./board_root" > /tmp/root_dir_name.txt
    clean_board >/dev/null # clear previous games data
 
    header "TREASURE HUNT GAME"
    

    info "Hi! Are you ready to play the greatest game of all times? [y/n]"
    read -r proceed
    
    if [ "$proceed" != "y" ]; then
        warning "Sad to see you go, but ok. Bye!" 
        clean_board
        exit 0
    fi

    success "Ok, let's start!"
    
    # Configuración del tablero
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

    info "Creating board with:"
    echo -e "• Levels: ${YELLOW}$depth${NC}"
    echo -e "• Directories per level: ${YELLOW}$width${NC}"
    echo -e "• Files per directory: ${YELLOW}$files${NC}"
    echo -e "• Directories will be named ${YELLOW}dir_xy${NC}"
    echo -e "• Files will be named ${YELLOW}file_N.txt${NC}"
    
    create_board "$depth" "$width" "$files"
    success "Board created successfully!"
    info "Files are located in: $(cat /tmp/root_dir_name.txt)"

    # Selección de modo
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
    
    fill_board "$mode"
    success "The treasure has been hidden!"
    
    place_treasure "$mode" > /tmp/treasure_key.txt
    header "TREASURE HUNT BEGINS!"
    info "Look for the treasure in: $(cat /tmp/root_dir_name.txt)"
    
    # Búsqueda del tesoro
    while true; do
        read -p "Enter the full path (./board_root/...): " file_path
        
        local is_found
        is_found=$(verify "$mode" "$file_path")
        if [ "$is_found" -eq 1 ]; then
            echo -e "\n${GREEN}"
            echo "===================================="
            echo "   CONGRATULATIONS! YOU FOUND IT!"
            echo "===================================="
            echo -e "${NC}"
            break
        else
            warning "This is not the treasure :c"
            read -p "Try again? [y/n]: " try_again
            
            if [ "$try_again" != "y" ]; then
                 warning "The biggest loser, is the one who gives up..."
                warning "The treasure was hidden in: $(cat /tmp/treasure_file_path.txt)"
                clean_board >/dev/null
                info "Goodbye!"
                exit 0
            fi
        fi
    done
    
    clean_board
}

init_game