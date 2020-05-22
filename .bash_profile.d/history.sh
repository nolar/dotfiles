#!/usr/bin/env bash

# Keep history in multiple sessions.
# See: http://linuxcommando.blogspot.ru/2007/11/keeping-command-history-across-multiple.html
shopt -s histappend
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignorespace
export HISTSIZE="99999"
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;} history -a"

update_terminal_cwd() {
    true
}
