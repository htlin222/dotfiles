#!/bin/bash
# title: "rearrange_pdf"
# author: Hsieh-Ting Lin
# date: "2024-04-17"
# version: 1.0.0
# description:
# --END-- #

eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init - | sed s/precmd/chpwd/g)"

python ~/pyscripts/rearrange_pdf.py "$1"
