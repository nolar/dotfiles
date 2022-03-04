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
    kubectl "$@"
}
function znodes () {
    kubectl get nodes \
      -L dedicated \
      -L aws.amazon.com/spot \
      -L beta.kubernetes.io/instance-type \
      -L topology.kubernetes.io/zone \
      "$@"
}
function zl () {
    kubectl logs "$@"
}
function za () {
    # See also: kubectl api-resources
    kubectl get all,pvc,secret,pcs
}
function zx () {
    if [[ " $* " == *" -- "* ]]; then
        kubectl exec -it "$@"
    else
        kubectl exec -it "$@" -- bash
    fi
}
function zy () {
    if [[ $# -ge 2 ]] ; then
        kubectl get -o yaml "$@"
    elif [[ "$1" == *"/"* ]] ; then
        kubectl get -o yaml "$@"
    else
        kubectl get -o yaml pod "$@"
    fi
}
function zd () {
    if [[ $# -ge 2 ]] ; then
        kubectl describe "$@"
    elif [[ "$1" == *"/"* ]] ; then
        kubectl describe "$@"
    else
        kubectl describe pod "$@"
    fi
}
function zw () {
    if [[ $# -ge 2 ]] ; then
        kubectl get --watch "$@"
    elif [[ "$1" == *"/"* ]] ; then
        kubectl get --watch "$@"
    else
        kubectl get --watch pod "$@"
    fi
}

function __z () {
    COMP_WORDS=( kubectl "${COMP_WORDS[@]:1}" )
    COMP_CWORD=$(($COMP_CWORD + 0))
    __start_kubectl
}
function __zl () {
    COMP_WORDS=( kubectl logs "${COMP_WORDS[@]:1}" )
    COMP_CWORD=$(($COMP_CWORD + 1))
    __start_kubectl
}
function __zx () {
    COMP_WORDS=( kubectl exec -it "${COMP_WORDS[@]:1}" )
    COMP_CWORD=$(($COMP_CWORD + 2))
    __start_kubectl
}
function __zy () {
    if [[ ${#COMP_WORDS[@]} -ge 3 ]] ; then
        COMP_WORDS=( kubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    elif [[ "${COMP_WORDS[1]}" == *"/"* ]] ; then
        COMP_WORDS=( kubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    else
        COMP_WORDS=( kubectl get pod ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 2))
    fi
    __start_kubectl
}
function __zd () {
    if [[ ${#COMP_WORDS[@]} -ge 3 ]] ; then
        COMP_WORDS=( kubectl describe ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    elif [[ "${COMP_WORDS[1]}" == *"/"* ]] ; then
        COMP_WORDS=( kubectl describe ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    else
        COMP_WORDS=( kubectl describe pod ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 2))
    fi
    __start_kubectl
}
function __zw () {
    # FIXME: with --watch, kubectl autocompletion fails with bash errors.
    # FIXME: but it is okay for us to not have --watch in autocomplete, only in the alias.
    if [[ ${#COMP_WORDS[@]} -ge 3 ]] ; then
        COMP_WORDS=( kubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    elif [[ "${COMP_WORDS[1]}" == *"/"* ]] ; then
        COMP_WORDS=( kubectl get ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 1))
    else
        COMP_WORDS=( kubectl get pod ${COMP_WORDS[@]:1} )
        COMP_CWORD=$(($COMP_CWORD + 2))
    fi
    __start_kubectl
}
complete -o default -o nospace -F __z z
complete -o default -o nospace -F __zl zl
complete -o default -o nospace -F __zx zx
complete -o default -o nospace -F __zy zy
complete -o default -o nospace -F __zd zd
complete -o default -o nospace -F __zw zw

# Make them usable in sub-shells, e.g. in `watch z get pod`
export -f z zl zx zy zd zw za znodes
