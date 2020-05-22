#!/usr/bin/env bash

# Go up 1 level. Just for convenience.
function .. () {
    cd ..
}

# Execute an arbitrary command ($2...) in the specified directory ($1).
function at () {
    local dir="$1"
    shift
    ( cd "$dir" && exec "$@" )
}

# CD to the source code directory of the specified project under ~/src (or $SRC_DIR):
function src () {
    cd ${SRC_DIR:-~/src}/"${1:-}"
}

# Create a dir if absent, then cd into it.
function mkcd () {
    mkdir -p -- "$1" &&
    cd -- "$1"
}

#
# Autocompletions.
#

function _at () {
    if [[ ${COMP_CWORD} -eq 1 ]] ; then
        _cd
    else
        _command_offset 2
    fi
    return $?
}

# TODO: make it resolve "a b" dirs nicely, same as `cd`. Now: unescaped.
function _src() {
    COMPREPLY=()
    local curr="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local tokens=()

    local srcdir="${SRC_DIR:-"${HOME}/src"}"

    # Lookup the directories normally.
    local srcpaths=$( compgen -d -- "${srcdir}"/"${curr}" )

    # Also try to guess by inclusion of the substring, as an addition to normal dir lookup.
    # But look only for the dirs, not for the files.
    if [[ "${curr}" ]] ; then
        local srcglobs=$( compgen -G "${srcdir}"/'*'"${curr}"'*'/ )
#        local srcpaths+=$'\n'"$srcglobs"
#
#        # FIXME: When there are dirs "abc-appname" & "aws-abc-appname", the completion
#        # FIXME: for "abc-app" suggests them both. But since their common *prefix* is "a" only,
#        # FIXME: the whole line is reduced from "abc-app" to "a" -- because bash assumes the prefixes.
#        # FIXME: When there are no common prefix (e.g. "z-abc-appname" is added),
#        # FIXME: then no reduction happens.
#        # FIXME: As a workaround, we return an empty-string or dot-dir option to override
#        # FIXME: any common prefixes. But it looks weird in the output.
#        # TODO: Here, we check if the number of globs is >=2. Make it more simple.
#        local arrglobs=( $srcglobs )
#        if [[ ${#arrglobs[@]} -gt 1 ]] ; then
#            local srcpaths+=$'\n''*'"$curr"'*'
#        fi

#        # Instead of auto-completing with the globs, hust print the hints.
#        echo ""
#        echo "Hints:"
#        column <<< "$srcglobs"
    fi

    # Convert the paths to the compspec tokens.
    local tmp
    while read -r tmp; do
        # Prevent empty output (e.g. empty dirs) to be processed.
        if [[ "$tmp" ]] ; then

            # And add trailing slashes to them (if not yet there), as they are the dirs.
            tmp="${tmp%%+(/)}/"

            # Remove srcdir prefix from all found suggestions:
            # they are the full paths, we want only the relative paths.
            tmp="${tmp##"${srcdir}"/}"

            # Put the completion option to the shell-consumed resulting variable.
            # TODO: Make sure escaping is OK. E.g. a dir named "~/src/a b"
            COMPREPLY+=( "${tmp}" )
        fi
    done <<< "$srcpaths"

}

complete -F _at at
complete -F _cd mkcd
complete -o nospace -F _src src
