#!/bin/bash

pkglist=(
    # vimっぽく使う. 設定は https://qiita.com/y-mattun/items/45776b7e1942edb2f727
    vscodevim.vim
    # python関連
    ms-python.python
    ms-python.vscode-pylance
    njpwerner.autodocstring
    ms-toolsai.jupyter
    ms-toolsai.jupyter-keymap
    ms-toolsai.jupyter-renderers
    # docker 関連(remote-containersは別)
    ms-azuretools.vscode-docker
    # markdown
    shd101wyy.markdown-preview-enhanced
    yzhang.markdown-all-in-one
    bierner.markdown-mermaid
    ### 見た目関連
    # 全角スペースを強調
    saikou9901.evilinspector
    # 文末スペースの強調
    shardulm94.trailing-spaces
    # TODO とかを強調
    aaron-bond.better-comments
    # 対応する括弧で色分け
    CoenraadS.bracket-pair-colorizer
    # テーマ
    Equinusocio.vsc-material-theme
    Equinusocio.vsc-community-material-theme
    # アイコン表示
    pkief.material-icon-theme
    equinusocio.vsc-material-theme-icons
    # スペルチェック(こういうのからは卒業したいが)
    streetsidesoftware.code-spell-checker
    # ファイルパスの補完
    christian-kohler.path-intellisense
    # 補完
    VisualStudioExptTeam.vscodeintellicode
    ### その他
    # TODO tree
    Gruntfuggly.todo-tree
    # コンテナ利用
    ms-vscode-remote.remote-containers
    # live share
    ms-vsliveshare.vsliveshare
)

for i in ${pkglist[@]}; do
  code --install-extension $i
done
