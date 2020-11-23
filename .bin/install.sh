#/bin/bash

set -ex

DOTFILE_DIR=$(cd $(dirname $0);cd ../; pwd)
cd ${DOTFILE_DIR}

EXEC_DATETIME=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=${HOME}/backup_${EXEC_DATETIME}

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
    ln -snfv ${DOTFILE_DIR}/$f $HOME/$f
  fi
  if [ -d $f ]; then
    for filepath in $(find $f -type f)
    do
      if [ -e ${HOME}/${filename} ]; then
        mkdir -p ${BACKUP_DIR}/$(dirname ${filepath})
        cp -RL ${filepath} ${BACKUP_DIR}/${filepath}
        echo "${filepath} is copied to backup directory"
      fi
      ln -snfv ${DOTFILE_DIR}/${filepath} $HOME/${filepath}
    done
  fi
done
