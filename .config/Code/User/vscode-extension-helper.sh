#!/bin/bash

cd "$(dirname "$0")"

for ext in $(code --list-extensions); do
  if ! grep -iq $ext vscode-extension.sh; then
    echo "this extension is not in pkglist of install shell: ${ext}";
  fi
done
