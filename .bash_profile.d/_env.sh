#!/usr/bin/env bash

# For colorful "ls".
export CLICOLOR=yes
export GREP_OPTIONS="--color=auto"
export LANG=en_US.UTF-8
export LESS="-S -R"
export EDITOR=mcedit
export VIEWER=less  # bzless, but it has no Shift+F streaming

# For python's sphinx, see http://stackoverflow.com/a/19961403/857383
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# User's in folder is to override all other, so it comes last.
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export PATH=~/env/bin:$PATH
export PATH=~/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=~/lib:$LD_LIBRARY_PATH

# Other shell & session configs.
ulimit -n 2048
