#!/usr/bin/env bash
#
# Kubernetes scripts and helpers.
#

# See: `complete | grep kube`
alias ns=kubens
alias ctx=kubectx
complete -F _kube_namespaces ns
complete -F _kube_contexts ctx

# Kubectl shortcuts.
function z () {
    zkubectl "$@"
}
function znodes () {
    zkubectl get nodes \
      -L dedicated \
      -L aws.amazon.com/spot \
      -L beta.kubernetes.io/instance-type \
      -L topology.kubernetes.io/zone \
      "$@"
}
function zl () {
    zkubectl logs "$@"
}
function za () {
    # See also: zkubectl api-resources
    zkubectl get all,pvc,secret,pcs
}
function zx () {
    if [[ " $* " == *" -- "* ]]; then
        zkubectl exec -it "$@"
    else
        zkubectl exec -it "$@" -- bash
    fi
}
function zy () {
    if [[ $# -ge 2 ]] ; then
        zkubectl get -o yaml "$@"
    elif [[ "$1" == *"/"* ]] ; then
        zkubectl get -o yaml "$@"
    else
        zkubectl get -o yaml pod "$@"
    fi
}
function zd () {
    if [[ $# -ge 2 ]] ; then
        zkubectl describe "$@"
    elif [[ "$1" == *"/"* ]] ; then
        zkubectl describe "$@"
    else
        zkubectl describe pod "$@"
    fi
}
function zw () {
    if [[ $# -ge 2 ]] ; then
        zkubectl get --watch "$@"
    elif [[ "$1" == *"/"* ]] ; then
        zkubectl get --watch "$@"
    else
        zkubectl get --watch pod "$@"
    fi
}

function __z () {
    COMP_WORDS=( zkubectl "${COMP_WORDS[@]:1}" )
    COMP_CWORD=$(($COMP_CWORD + 0))
    __start_zkubectl
}
function __zl () {
    COMP_WORDS=( zkubectl logs "${COMP_WORDS[@]:1}" )
    COMP_CWORD=$(($COMP_CWORD + 1))
    __start_zkubectl
}
function __zx () {
    COMP_WORDS=( zkubectl exec -it "${COMP_WORDS[@]:1}" )
    COMP_CWORD=$(($COMP_CWORD + 2))
    __start_zkubectl
}
function __zy () {
    if [[ ${#COMP_WORDS[@]} -ge 3 ]] ; then
        COMP_WORDS=( zkubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    elif [[ "${COMP_WORDS[1]}" == *"/"* ]] ; then
        COMP_WORDS=( zkubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    else
        COMP_WORDS=( zkubectl get pod ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 2))
    fi
    __start_zkubectl
}
function __zd () {
    if [[ ${#COMP_WORDS[@]} -ge 3 ]] ; then
        COMP_WORDS=( zkubectl describe ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    elif [[ "${COMP_WORDS[1]}" == *"/"* ]] ; then
        COMP_WORDS=( zkubectl describe ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    else
        COMP_WORDS=( zkubectl describe pod ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 2))
    fi
    __start_zkubectl
}
function __zw () {
    # FIXME: with --watch, zkubectl autocompletion fails with bash errors.
    # FIXME: but it is okay for us to not have --watch in autocomplete, only in the alias.
    if [[ ${#COMP_WORDS[@]} -ge 3 ]] ; then
        COMP_WORDS=( zkubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    elif [[ "${COMP_WORDS[1]}" == *"/"* ]] ; then
        COMP_WORDS=( zkubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    else
        COMP_WORDS=( zkubectl get pod ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 2))
    fi
    __start_zkubectl
}
complete -o default -o nospace -F __z z
complete -o default -o nospace -F __zl zl
complete -o default -o nospace -F __zx zx
complete -o default -o nospace -F __zy zy
complete -o default -o nospace -F __zd zd
complete -o default -o nospace -F __zw zw

# Make them usable in sub-shells, e.g. in `watch z get pod`
export -f z zl zx zy zd zw za znodes
