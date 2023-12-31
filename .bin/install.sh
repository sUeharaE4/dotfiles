#!/bin/bash

DOTFILE_DIR=$(cd "$(dirname "$0")" || exit 1;cd ../; pwd)
cd "${DOTFILE_DIR}" || exit 1

EXEC_DATETIME=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=${HOME}/backup_${EXEC_DATETIME}
DEIN_DIR=${HOME}/.cache/dein

print_msg () {
  echo "### $1"
}

# check requirements
if ! command -v curl &> /dev/null
then
  print_msg "curl could not be found. please install before exec this script"
  exit
fi

if ! command -v git &> /dev/null
then
  print_msg "git could not be found. please install before exec this script"
  exit
fi

print_msg "exec datetime: ${EXEC_DATETIME}"
print_msg "your dotfiles are copied to ${BACKUP_DIR}"
print_msg "please remove backup when you feel anything alright"

mkdir "${BACKUP_DIR}"

for f in .??*
do
  if [ "$f" == ".git" ] \
  || [ "$f" == ".bin" ]; then
    continue
  fi
  if [ -f "$f" ]; then
    if [ -f "${HOME}"/"$f" ]; then
      cp -RL "$f" "${BACKUP_DIR}"/"$f"
      print_msg "$f is copied to backup directory"
    fi
    cp -f "$f" "$HOME"/"$f"
    ln -snfv "${DOTFILE_DIR}"/"$f" "$HOME"/"$f"
  fi

  if [ -d "$f" ]; then
    for filepath in $(find "$f" -type f)
    do
      if [ -e "${HOME}"/"${filepath}" ]; then
        mkdir -p "${BACKUP_DIR}"/"$(dirname "${filepath}")"
        cp -RL "${filepath}" "${BACKUP_DIR}"/"${filepath}"
        print_msg "${filepath} is copied to backup directory"
      fi
      mkdir -p "${HOME}"/"$(dirname "${filepath}")"
      cp -f "${filepath}" "$HOME"/"${filepath}"
      ln -snfv "${DOTFILE_DIR}"/"${filepath}" "$HOME"/"${filepath}"
    done
  fi
done

if ! command -v fzf &> /dev/null
then
  print_msg "fzf could not be found. some git aliase needs fzf"
  read -n 1 -r -p "install fzf? [y/n] >" install_fzf
  if [[ "${install_fzf}" = [Yy] ]]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  fi
fi

if [ ! -e "${DEIN_DIR}" ]; then
  print_msg "${DEIN_DIR} is not exists."
  print_msg "you may not have dein which plugin manager of vim."
  read -n 1 -r -p "install dein? [y/n] >" install_dein
  if [[ "${install_dein}" = [Yy] ]]; then
    curl \
    https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh \
    > dein_installer.sh
    sh ./dein_installer.sh "${DEIN_DIR}"
    rm -rf ./dein_installer.sh
  fi
fi

if ! command -v mdr &> /dev/null
then
  print_msg "mdr could not be found. vim markdown preview is need mdr"
  read -n 1 -r -p "install mdr? [y/n] >" install_mdr
  if [[ "${install_mdr}" = [Yy] ]]; then
    curl -L https://github.com/MichaelMure/mdr/releases/download/v0.2.5/mdr_linux_amd64 -o mdr_linux_amd64
    sudo chmod +x mdr_linux_amd64
    sudo mv mdr_linux_amd64 /usr/local/bin/mdr
  fi
fi

if ! command -v ctags &> /dev/null
then
  print_msg "ctags could not be found. vim tag jump is need ctags"
  print_msg "to install ctags run command bellow"
  print_msg "Debean: apt-get install exuberant-ctags"
  print_msg "RedHat: yum install ctags"
fi

if ! command -v shellcheck &> /dev/null
then
  print_msg "shellcheck could not be found."
  print_msg "to install shellcheck run command bellow"
  print_msg "Debean: apt-get install shellcheck"
  print_msg "RedHat: yum install epel-release ShellCheck"
  print_msg "macOS: brew install shellcheck"
fi

if ! command -v difft &> /dev/null
then
  print_msg "difft could not be found."
  print_msg "to install difftastic run command bellow"
  print_msg "Debean: ### need brew please see documentation ###"
  print_msg "macOS: brew install difftastic"
fi

