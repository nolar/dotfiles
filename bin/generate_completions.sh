#!/bin/bash
# Generate completion files for selected programs.
set -eu

PROGS=(zaws ztoken senza pierone)

for prog in "${@:-${PROGS[@]}}" ; do
    varn="_$( echo "$prog" | tr /a-z/ /A-Z/ )_COMPLETE"
    eval "export $varn=source"
    "$prog" | tee ~/.bash_completion.d/"${prog}.sh" || true
done
