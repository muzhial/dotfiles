#!/bin/bash

CURRENT_DIR=`pwd`
_file_=$(readlink -f "$0")
_file_dir_=$(dirname "$_file_")

ls -l $CURRENT_DIR
ls -l $_file_
ls -l $_file_dir_
