#/bin/bash

DOTFILE_DIR=$(cd $(dirname $0);cd ../; pwd)
cd ${DOTFILE_DIR}

EXEC_DATETIME=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=${HOME}/backup_${EXEC_DATETIME}

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
  read -p "install fzf? [yes/no] >" install_fzf
  if [ "${install_fzf}" in [Yy]|[Yy][Ee][Ss] ]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  fi
fi


