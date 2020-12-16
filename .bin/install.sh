#/bin/bash

DOTFILE_DIR=$(cd $(dirname $0);cd ../; pwd)
cd ${DOTFILE_DIR}

EXEC_DATETIME=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=${HOME}/backup_${EXEC_DATETIME}
DEIN_DIR=${HOME}/.cache/dein

# check requirements
if ! command -v curl &> /dev/null
then
  echo "curl could not be found. please install before exec this script"
  exit
fi

if ! command -v git &> /dev/null
then
  echo "git could not be found. please install before exec this script"
  exit
fi

echo "exec datetime: ${BACKUP_DIR}"
echo "your dotfiles are copied to ${EXEC_DATETIME}"
echo "please remove backup when you feel anything alright"

mkdir ${BACKUP_DIR}

for f in .??*
do
  if [ "$f" == ".git" ] \
  || [ "$f" == ".bin" ]; then
    continue
  fi
  if [ -f ${HOME}/$f ]; then
    cp -RL $f ${BACKUP_DIR}/$f
    echo "$f is copied to backup directory"
    cp -f $f $HOME/$f
    ln -snfv ${DOTFILE_DIR}/$f $HOME/$f
  fi
  if [ -d $f ]; then
    for filepath in $(find $f -type f)
    do
      if [ -e ${HOME}/${filename} ]; then
        mkdir -p ${BACKUP_DIR}/$(dirname ${filepath})
        cp -RL ${filepath} ${BACKUP_DIR}/${filepath}
        echo "${filepath} is copied to backup directory"
        mkdir -p ${HOME}/$(dirname ${filepath})
        cp -f ${filepath} $HOME/${filepath}
      fi
      ln -snfv ${DOTFILE_DIR}/${filepath} $HOME/${filepath}
    done
  fi
done

if ! command -v fzf &> /dev/null
then
  echo "fzf could not be found. some git aliase needs fzf"
  read -n1 -p "install fzf? [y/n] >" install_fzf
  if [[ "${install_fzf}" = [Yy] ]]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  fi
fi

if [ ! -e ${DEIN_DIR} ]; then
  echo "${DEIN_DIR} is not exists."
  echo "you may not have dein which plugin manager of vim."
  read -n1 -p "install dein? [y/n] >" install_dein
  if [[ "${install_dein}" = [Yy] ]]; then
    curl \
    https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh \
    > dein_installer.sh
    sh ./dein_installer.sh ${DEIN_DIR}
    rm -rf ./dein_installer.sh
  fi
fi

if ! command -v mdr &> /dev/null
then
  echo "mdr could not be found. vim markdown preview is need mdr"
  read -n1 -p "install mdr? [y/n] >" install_mdr
  if [[ "${install_mdr}" = [Yy] ]]; then
    curl -L https://github.com/MichaelMure/mdr/releases/download/v0.2.5/mdr_linux_amd64 -o mdr_linux_amd64
    sudo chmod +x mdr_linux_amd64
    sudo mv mdr_linux_amd64 /usr/local/bin/mdr
  fi
fi

