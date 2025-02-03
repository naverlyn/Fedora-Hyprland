#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# ZSH and oh-my-zsh & Optional Pokemon Color Scrips #

zsh=(
  eza
  fzf
  zsh 
  util-linux
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_zsh.log"

# Check if the log file already exists, if yes, append a counter to make it unique
COUNTER=1
while [ -f "$LOG" ]; do
  LOG="Install-Logs/install-$(date +%d-%H%M%S)_${COUNTER}_zsh.log"
  ((COUNTER++))
done

# Installing zsh packages
printf "${NOTE} Installing core zsh packages...${RESET}\n"
for ZSHP in "${zsh[@]}"; do
  install_package "$ZSHP"
  if [ $? -ne 0 ]; then
    echo -e "${ERROR} - $ZSHP Installation failed. Check the install log."
    exit 1
  fi
done

printf "\n%.0s" {1..1}

## Optional Pokemon color scripts
while true; do
    read -p "${CAT} OPTIONAL - Do you want to add ${YELLOW}Pokemon color scripts${RESET}? (y/n): " choice
    case "$choice" in
        [Yy]*)
            if [ -d "pokemon-colorscripts" ]; then
                cd pokemon-colorscripts && git pull && sudo ./install.sh && cd ..
            else
                git clone --depth 1 https://gitlab.com/phoneybadger/pokemon-colorscripts.git &&
                cd pokemon-colorscripts && sudo ./install.sh && cd ..
            fi
            sed -i '/#pokemon-colorscripts --no-title -s -r/s/^#//' assets/.zshrc >> "$LOG" 2>&1

			# commenting out fastfetch since pokemon was chosen to install
            sed -i '/^fastfetch -c $HOME\/.config\/fastfetch\/config-compact.jsonc/s/^/#/' assets/.zshrc >> "$LOG" 2>&1
            
			echo "${NOTE} ${MAGENTA}Pokemon-colorscripts${RESET} installation process completed" 2>&1 | tee -a "$LOG"
            break
            ;;
        [Nn]*) 
            echo "${MAGENTA} You chose not to install Pokemon Color Scripts." 2>&1 | tee -a "$LOG"
            break
            ;;
        *)
            echo "Please enter 'y' for yes or 'n' for no." 2>&1 | tee -a "$LOG"
            ;;
    esac
done

printf "\n"

# Install Oh My Zsh, plugins, and set zsh as default shell
if command -v zsh >/dev/null; then
  printf "${NOTE} Installing ${SKY_BLUE}Oh My Zsh and plugins${RESET} ...\n"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
      sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
  else
      echo "${INFO} Directory .oh-my-zsh already exists. Skipping re-installation." 2>&1 | tee -a "$LOG"
  fi
  # Check if the directories exist before cloning the repositories
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
      git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
  else
      echo "${INFO} Directory zsh-autosuggestions already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
  fi

  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true
  else
      echo "${INFO} Directory zsh-syntax-highlighting already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
  fi
  
  # Check if ~/.zshrc and .zprofile exists, create a backup, and copy the new configuration
  if [ -f "$HOME/.zshrc" ]; then
      cp -b "$HOME/.zshrc" "$HOME/.zshrc-backup" || true
  fi

  if [ -f "$HOME/.zprofile" ]; then
      cp -b "$HOME/.zprofile" "$HOME/.zprofile-backup" || true
  fi
  
  # Copying the preconfigured zsh themes and profile
  cp -r 'assets/.zshrc' ~/
  cp -r 'assets/.zprofile' ~/

  printf "${NOTE} Changing default shell to ${MAGENTA}zsh${RESET}..."
  printf "\n%.0s" {1..2}
  while ! chsh -s $(which zsh); do
      echo "${ERROR} Authentication failed. Please enter the correct password." 2>&1 | tee -a "$LOG"
      sleep 1
  done
  printf "${INFO} Shell changed successfully to ${MAGENTA}zsh${RESET}" 2>&1 | tee -a "$LOG"

fi

printf "\n%.0s" {1..2}

