#!/usr/bin/env bash

# Bash autocomplete (all others, Mac OS X & macports specific):
export USER_BASH_COMPLETION_DIR=~/.bash_completion.d
if [ -f /opt/local/etc/bash_completion ]; then
  . /opt/local/etc/bash_completion
fi
if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi
