#!/bin/bash

export PATH=$PATH:~/.local/bin
cp -r $HOME/ArchK1T/dotfiles/* $HOME/.config/
pip install konsave
konsave -i $HOME/ArchK1T/kde.knsv
sleep 1
konsave -a kde
