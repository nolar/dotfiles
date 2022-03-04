#!/usr/bin/env bash
#
# Set the bash prompt according to:
#
# * current timestamp.
# * the active virtualenv or pyenv.
# * the git branch and its status.
# * the exit status of the previous command.
# * the sudo/root privileges.
#
# Installation:
#
# Save this file as ~/.bash_prompt
# Add the following line to the end of your ~/.bashrc or ~/.bash_profile:
#        . ~/.bash_prompt
#

# The username & hostname change rarely, so we can avoid calculating them on every command.
# These values must be lower-case here.
HIDDEN_USERS=( nolar svasilyev )
HIDDEN_HOSTS=( sv-pro nolaair nolair datafoldpro )

# Speed-optimized way of returning values from functions.
# See: http://rus.har.mn/blog/2010-07-05/subshells/
# Usage: assign varname "some value"
# Usage: assign $varref "some value"
function assign () {
    printf -v "$1" '%s' "${2:-}"
}
function append () {
    printf -v "$1" '%s' "${!1:-}${2:-}"
}

# Just assign a text to a variable. Mostly for symmetry with `ansi`.
function text () {
    local resultvar="$1" && shift
    assign "$resultvar" "$*"
}

# Generate an ANSI code with foreground & background 8-bit colors and other modes.
# See color codes at https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
# Usage: ansi VAR [FG-COLOR [BG-COLOR]] [-- OTHER-CODES...]
function ansi () {
    local resultvar="$1" && shift

    # Avoid using getopts, as it can be too time-consuming (TODO: check; not certain).
    local fg=""
    local bg=""
    if [[ $# -gt 0 && "${1:-}" != "--" ]]; then
        local fg="${1:+;38;5;$1}"
        shift
    fi
    if [[ $# -gt 0 && "${1:-}" != "--" ]]; then
        local bg="${1:+;48;5;$1}"
        shift
    fi
    if [[ $# -gt 0 && "${1:-}" != "--" ]]; then
        assign "$resultvar"
        return 1
    else
        shift  # when either no args, or $1 is '--'
    fi
    local IFS=';'                                   # join $* with ";", not spaces
    local others="${*:+;$*}"                        # prefix with ";" -- removed below
    local result="${fg}${bg}${others}"              # combine all codes together
    local result="${result#';'}"                    # if it starts with $others only
    local result="${result:+"\\033[${result}m"}"    # one combined ansi sequence
    local result="${result:+"\\[${result}\\]"}"     # non-printable prompt parts
    assign "$resultvar" "$result"
}

# Join all non-empty segments (passed by their names) with their relevant separators.
function show () {
    local resultvar="$1" && shift

    local prev=""
    local result=""
    local rstansi && ansi rstansi -- 0

    # Process every requested segment in order, and join accordingly.
    for name in "$@" ; do

        # Conventional names of the global/caller variables, which define the segment.
        local sepansivar="${prev}_${name}_ANSI[@]"
        local septextvar="${prev}_${name}_TEXT"
        local segansivar="${name}_ANSI[@]"
        local segtextvar="${name}_TEXT"
        local segiconvar="${name}_ICON"

        # Skip the empty segments completely and asap, without even preparing ansi/icon.
        if [[ -z "${!segtextvar}" ]]; then
            continue
        fi

        # If there is some text to show, then pre-format ansi/icon/etc.
        local segansi && ansi segansi "${!segansivar}"
        local segtext && text segtext "${!segtextvar}"
        local segicon && text segicon "${!segiconvar}"
        local content="${segtext:+${segicon}}${segtext:+${segicon:+ }}${segtext}"

        local curr_bg="${name}_ANSI[1]"
        local prev_bg="${prev}_ANSI[1]"

        # If there is a separator defined, use it. Otherwise, use the hard-coded separator.
        # The hard-coded is either hard (different backgrounds) or soft (same background).
        if [[ -z "${prev}" ]]; then
            true  # noop
        elif [[ "${!septextvar+x}" ]]; then
            local sepansi && ansi sepansi "${!sepansivar}"
            local septext && text septext "${!septextvar}"
            local septail && ansi septail
            result="${result}${sepansi}${septext}${septail}"
            prev=""  # disable prefixing space for custom separators
        elif [[ "${!curr_bg}" == "${!prev_bg}" ]]; then
            local sepansi && ansi sepansi 14 "${!curr_bg}" -- 22
            local septext && text septext "${SOFT_SEP}"
            local septail && ansi septail
            result="${result} ${sepansi}${septext}${septail}"  # TODO: make space a part of the text?
        elif [[ "${!curr_bg}" != "${!prev_bg}" ]]; then
            local sepansi && ansi sepansi "${!curr_bg}" "${!prev_bg}" -- 22 7  # 7:reverse
            local septext && text septext "${HARD_SEP}"
            local septail && ansi septail -- 27  # 27:no-reverse
            result="${result} ${sepansi}${septext}${septail}"  # TODO: make space a part of the text?
        fi

        # Format the main segment content, trimmed.
        # TODO: And why did we trim? What is the case? What if I want spaces for PS2?
        # TODO: because of the pseudo-empty END section (space-only should be shown,. but mo spaces)?
        if [[ "${content}" == " " ]] ; then
            content=""
        fi
#        result="${result}${rstansi}${segansi}${prev:+${content:+ }}${content%%+( )}"
        result="${result}${rstansi}${segansi}${prev:+${content:+ }}${content}"

        # And keep the current segment name to find the relevant separator for the next one.
        local prev="$name"
    done

    assign "$resultvar" "$result"
}

# Determine the branch/state information for this git repository.
function detect_git_status {
    local resultvar="$1" && shift

    # Capture the output of the "git status" command.
    local git_status="$(which git >/dev/null && git status 2>/dev/null)"

    # Ignore non-git directories, or if git is just absent/broken.
    if [[ -z "${git_status}" ]]; then
        assign "$resultvar"
        return 0
    fi

    # Set color based on clean/staged/dirty.
    if [[ "${git_status}" =~ "working tree clean" ]]; then
        fg=10
    elif [[ "${git_status}" =~ "Changes to be committed" ]]; then
        fg=11
    else
        fg=9
    fi

    # Set arrow icon based on status against remote.
    remote_pattern="Your branch is (.*) '"
    if [[ "${git_status}" =~ ${remote_pattern} ]]; then
        if [[ ${BASH_REMATCH[1]} == "ahead of" ]]; then
            remote=" ↑"
        elif [[ ${BASH_REMATCH[1]} == "behind" ]]; then
            remote=" ↓"
        else
            remote=""
        fi
    else
        remote=""
    fi

    diverge_pattern="Your branch and (.*) have diverged"
    if [[ "${git_status}" =~ ${diverge_pattern} ]]; then
        remote=" ↕"
    fi

    # Get the name of the branch.
    branch_pattern="^On branch ([^${IFS}]*)"
    if [[ "${git_status}" =~ ${branch_pattern} ]]; then
        branch="${BASH_REMATCH[1]}"
    fi

    # Are we rebasing?
    branch_pattern="rebasing branch '([^']*)' on '([^']*)'"
    if [[ "${git_status}" =~ ${branch_pattern} ]]; then
        branch="${BASH_REMATCH[1]}"
        remote=" ⅋ ${BASH_REMATCH[2]}"
        fg=9
    fi

    # Set the final branch string.
    local gitansi && ansi gitansi ${fg}
    assign "$resultvar" "${gitansi}${branch}${remote}"
}

# Also support root accounts on the remote machines, and `sudo -s` shell.
function detect_root_icon () {
    local resultvar="$1" && shift

    if [[ "${UID:-666}" -eq 0 ]]; then
        local prefix & ansi prefix -- 5    # blink-on
        local suffix & ansi suffix -- 25   # blink-off
        assign "$resultvar" "${prefix}⚡${suffix}"
    fi
}

# Determine active Python virtualenv details.
function detect_virtualenv () {
    local resultvar="$1" && shift

    if [[ -n "$PYENV_VERSION" ]]; then
        assign "$resultvar" "$PYENV_VERSION"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        assign "$resultvar" "${VIRTUAL_ENV##*/}"  # i.e. `basename`
    else
        assign "$resultvar"
    fi
}

# Refresh the k8s env vars only if the config is changed. Otherwise, it is too slow.
: ${kubectl:=zkubectl}
_k8s_config=$HOME/.kube/config
_k8s_cached="${TMPDIR}/k8s-prompt-cache"
_k8s_status=()
function refresh_k8s_status () {
    if [[ ! -e "$_k8s_config" ]] ; then
        # No kubernetes? No prompt! Nothing to cache.
        _k8s_status=()

    elif [[ ! -s "$_k8s_cached" || "$_k8s_config" -nt "$_k8s_cached" ]] ; then
        # Retrieve the kubernetes context via the CLI invocations.
        local cl=$( $kubectl config view --minify --output 'jsonpath={..context.cluster}' )
        local ns=$( $kubectl config view --minify --output 'jsonpath={..context.namespace}' )
        _k8s_status=( "$cl" "$ns" )

        # Cache the results into a file. Command invocation is slow, file reading is fast.
        echo "${_k8s_status[@]}" > "$_k8s_cached"

    else
        # Re-read the cache every time, since it could be generated by other active shells.
        # We assume that reading is fast, and no in-memory caching of the in-file cache is needed.
        read -a _k8s_status < "$_k8s_cached"
    fi
}
function detect_k8s_cluster () {
    local resultvar="$1" && shift
    refresh_k8s_status
    if [[ -n "${_k8s_status[0]}" ]]; then
        assign "$resultvar" "${_k8s_status[0]}"
    else
        assign "$resultvar"
    fi
}
function detect_k8s_namespace () {
    local resultvar="$1" && shift
    refresh_k8s_status
    if [[ -n "${_k8s_status[1]}" && "${_k8s_status[1]}" != "default" ]]; then
        assign "$resultvar" "${_k8s_status[1]}"
    else
        assign "$resultvar"
    fi
}

# Set the full bash prompt.
function set_bash_prompt () {
    local status=$?

#    # Coloring rules:
#    # * variable work context (cwd,git,venv) is bright;
#    # * system static info is dim;
#    # * time is semi-hidden;
#    # * same bg for everything -- to easily find the lines in the console history.
#    if [[ "${PYCHARM:-}" ]]; then
#        bak=""
#    else
#        bak="${bg_dk_blu}"
#    fi

#   # An attempt to restructure segments into one array var each.
#    local TIME=(      240 254 ""      " \t")
#    local USER=(      $((${UID:-666}?6:9)) 4 "" "\u")
#    local HOST=(      6   4   ""      "\h")
#    local PATH=(      11  4   ""      "\w")
#    local USER_HOST=( 6   4           "@")
#    local HOST_PATH=( 8   4           ":")
#    local VENV=(      220 22  "ⓔ "    "$(get_virtualenv)")
#    local PYENV=(     250 22  "🅟 "    "")
#    local GITS=(      12  19  ""     "$(get_git_status)")
#    local END=(       4   0   ""      " ")
#    local STATUS=(    15  1   ""      "${status##0}")

    local SOFT_SEP=""
    local HARD_SEP=""

    local TIME_TEXT=" \t"
    local TIME_ANSI=(240 253)

#    local USER_ICON && detect_root_icon USER_ICON
    local USER_TEXT=$( [[ " ${HIDDEN_USERS[@]} " =~ " $(whoami  |tr [[:upper:]] [[:lower:]]) " ]] || echo '\u' )
    local HOST_TEXT=$( [[ " ${HIDDEN_HOSTS[@]} " =~ " $(hostname|tr [[:upper:]] [[:lower:]]) " ]] || echo '\h' )
    local USER_ANSI=( $(( ${UID:-666} ? 6 : 9 )) 4)
    local HOST_ANSI=(6 4)

    local PATH_TEXT="\w"
    local PATH_ANSI=(11 4)
    local USER_HOST_TEXT="@"
    local USER_HOST_ANSI=(6 4)
    local HOST_PATH_TEXT=":"
    local HOST_PATH_ANSI=(8 4)

#    local KUBE_CL_ICON="🔆🌀🐝"  # "☸︎" "☸️ "
#    local KUBE_CL_ICON="☸️ "  # "☸︎" "☸️ "
    local KUBE_CL_ICON="🐝"  # "☸︎" "☸️ "
    local KUBE_CL_TEXT && detect_k8s_cluster KUBE_CL_TEXT
    local KUBE_CL_ANSI=(123 23)  # (220 22)
    local KUBE_NS_TEXT && detect_k8s_namespace KUBE_NS_TEXT
    local KUBE_NS_ANSI=(196 23)  # (220 22)
    local KUBE_CL_KUBE_NS_TEXT=":"
    local KUBE_CL_KUBE_NS_ANSI=( 196 )

    local VENV_ICON="🐍"  # "ⓔ " # "🅥 "
    local VENV_TEXT && detect_virtualenv VENV_TEXT
    local VENV_ANSI=(118 25)  # (220 22)
    local PYENV_ICON="🅟 "
    local PYENV_TEXT=""  #TODO! separately from venv?
    local PYENV_ANSI=(250 22)
    local GITS_TEXT && detect_git_status GITS_TEXT
    local GITS_ANSI=(116 19)
    local GITS_ICON=""
    local END_TEXT=" "
    local END_ANSI=(4 0)
    local STATUS_TEXT="${status##0}"
    local STATUS_ANSI=(15 1)

    local USER_MODE_TEXT="\\\$ "
    local USER_MODE_ANSI=(240 253)
    local USER_MODE_END_TEXT=""
    local NEXT_LINE_TEXT="  "
    local NEXT_LINE_ANSI=(240 253)
    local NEXT_LINE_END_TEXT=""

    local cwd && text cwd "\[\033]0;${PWD}\007\]"  # non-typical ansi, therefore explicitly here
    local txt && show txt TIME USER HOST PATH KUBE_CL KUBE_NS VENV GITS STATUS END
#    local txt && show txt TIME USER HOST PATH VENV GITS STATUS END
    local rst && ansi rst -- 0
    local usr && show usr USER_MODE END
    local nxt && show nxt NEXT_LINE END
    PS1="${cwd}${txt}${rst}\n${usr}${rst}"
    PS2="${nxt}${rst} "

    return $status
}

# FIXME: Too slow ~0.5s per call only for this: `time bash -c _has_parent_command`
function _has_parent_command () {
    local pattern="$1"
    local pid=$$
    while [[ "$pid" -ne 0 ]]; do
        local command="$( ps -o comm= -p $pid )"
        if [[ "$command" =~ "$pattern" ]]; then
            return 0
        fi
        pid="$( ps -o ppid= -p $pid )"
    done
    return 1
}

# Detect if we run under PyCharm, in which case different colors are used.
if _has_parent_command pycharm ; then
    PYCHARM="yes"
fi

# Tell bash to execute this function just before displaying its prompt.
if ! [[ "$PROMPT_COMMAND" =~ set_bash_prompt ]]; then
    PROMPT_COMMAND="set_bash_prompt${PROMPT_COMMAND:+;}$PROMPT_COMMAND"
fi

# Disable native virtualenv prompt (incl. pyenv), since we have our own.
export VIRTUAL_ENV_DISABLE_PROMPT=yes
