#!/bin/bash
# title: to_pdf
# date created: "2023-09-26"

marp --theme-set ./themes --html --images png "$1"
