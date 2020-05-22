#!/usr/bin/env bash

#alias ssh="~/.ssh/.compile && ssh"  # OR: compile manually on every change
#alias scp="~/.ssh/.compile && scp"  # OR: compile manually on every change
alias sshpw="ssh -o PreferredAuthentications=password"
alias scppw="scp -o PreferredAuthentications=password"
alias sshid="ssh -o IdentitiesOnly=yes"
alias scpid="scp -o IdentitiesOnly=yes"

# Bash autocomplete (ssh aliases):
_complete_ssh_hosts ()
{
    [ -r ~/.ssh/known_hosts ] && cat ~/.ssh/known_hosts | \
        cut -f 1 -d ' ' | \
        sed -e s/,.*//g | \
        grep -v ^# | \
        uniq | \
        grep -v "\[" ;
    [ -r ~/.ssh/config ] && cat ~/.ssh/config | \
        grep "^Host " | \
        sed 's/^Host //g' | \
        tr ' ' '\n' | \
        grep -v '\*|\?'
}
complete -o default -o nospace -W "$(_complete_ssh_hosts)" ssh scp sftp
