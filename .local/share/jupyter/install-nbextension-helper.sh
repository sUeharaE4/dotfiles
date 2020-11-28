#!/bin/bash

if ! command -v jupyter &> /dev/null
then
  echo "you can't use jupyter. be sure you installed conda and jupyter."
  echo "see {dotfiles_dir}/.config/conda"
  exit 1
fi

echo "jupyter notebook --generate-config"
echo "pip install jupyter_contrib_nbextensions"
echo "jupyter contrib nbextension install --user"
