#!/bin/bash

# Install GPU Switcher
curl -o gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip https://extensions.gnome.org/extension-data/gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
unzip gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip -d gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension

mkdir -p /usr/share/gnome-shell/extensions/gpu-switcher-supergfxctl@chikobara.github.io
mv gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension/* /usr/share/gnome-shell/extensions/gpu-switcher-supergfxctl@chikobara.github.io

rm gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension.zip
rm -rf gpu-switcher-supergfxctlchikobara.github.io.v9.shell-extension