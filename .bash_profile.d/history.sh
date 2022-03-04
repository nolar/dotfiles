#!/usr/bin/env bash

# Keep history in multiple sessions.
# See: http://linuxcommando.blogspot.ru/2007/11/keeping-command-history-across-multiple.html
shopt -s histappend
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignorespace
export HISTSIZE="99999"

# Append-clear-reload — to keep the history synced across sessions and tabs.
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;} history -a; history -c; history -r"

# Disable Ctrl-S session freezing, to enable the history navigation with CtrlR/CtrlS.
stty -ixon

update_terminal_cwd() {
    true
}
