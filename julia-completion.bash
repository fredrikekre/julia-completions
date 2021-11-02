#!/bin/bash

# Bash completion for julia (https://julialang.org/)
# MIT License, Copyright (c) 2021 Fredrik Ekre (https://github.com/fredrikekre/julia-completion)

# Notes to self:
# Uses
#   while IFS='' read -r line; do arr+=("$line"); done < <(cmd)
# instead of
#   mapfile -t arr < <(cmd)
# for compatibility with Bash 3.

# Guesstimate of what `bash_completion/_init_completion -s`
# does. Provided for compatibility where bash_completion
# is not installed.
# TODO: Need to handle the case where the cursor are before
# or in the middle of the current word so for now the script
# uses `bash_completion/_init_completion -s` if available.
# This function is taken from https://github.com/fredrikekre/jlpkg
__init_completion(){
    words=()
    prev=""
    cur=""
    cword="${COMP_CWORD}"
    split=false
    for (( i = 0; i < ${#COMP_WORDS[@]}; i++ )); do
        [[ ! $i > "${COMP_CWORD}" ]] && cur="${COMP_WORDS[$i]}"
        [[ i -gt 0 && ! $i > "${COMP_CWORD}" ]] && prev="${COMP_WORDS[$i-1]}"
        if [[ "${COMP_WORDS[$i]}" == = ]]; then
            words[-1]="${words[-1]}${COMP_WORDS[$i]}"
            if [[ ! $i > "${COMP_CWORD}" ]]; then
                ((cword --))
                if [[ ${words[-1]} == -* ]]; then
                    split=true
                    cur=""
                else
                    prev="${words[-2]}"
                    cur="${words[-1]}"
                fi
            fi
            # peek next
            if [[ $((i+1 < ${#COMP_WORDS[@]})) && -n "${COMP_WORDS[$i+1]}" ]]; then
                ((i++))
                words[-1]="${words[-1]}${COMP_WORDS[$i]}"
                if [[ ! $i > "${COMP_CWORD}" ]]; then
                    ((cword --))
                    if [[ ${words[-1]} == -* ]]; then
                        cur="${COMP_WORDS[$i]}"
                    else
                        cur="${words[-1]}"
                    fi
                fi
            fi
        else
            [[ $split == "true" ]] && prev="${words[-1]}"
            split=false
            words+=("$cur")
        fi
    done
}

_julia() {

    local cur prev words cword split
    if command -v _init_completion &> /dev/null ; then
        _init_completion -s
    else
        __init_completion
    fi

    COMPREPLY=()

    # julia options
    local opts="-v --version -h --help --help-hidden --project --project= -J --sysimage \
                -H --home --startup-file --handle-signals --sysimage-native-code \
                --compiled-modules -e --eval -E --print -L --load -t --threads -p --procs \
                --machine-file -i -q --quiet --banner --color --history-file --depwarn \
                --warn-overwrite --warn-scope -C --cpu-target -O --optimize -g --inline \
                --check-bounds --math-mode --code-coverage --track-allocation --bug-report"

    if [[ "$prev" == "--project" && "${split}" == "true" ]]; then
        # --project completes *Project.toml files and directories
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -f -X '!*Project.toml' -- "${cur}"; compgen -d -- "${cur}")
        compopt -o filenames
    elif [[ "${prev}" == "--sysimage" || "${prev}" == "-J" ]]; then
        # --sysimage completes *.so, *.dylib and directories
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(shopt -s extglob; compgen -f -X '!*.@(so|dylib)' -- "${cur}"; compgen -d -- "${cur}")
        compopt -o filenames
    elif [[ "${prev}" == "--home" || "${prev}" == "-H" ]]; then
        # --home completes directories
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -d -- "${cur}")
        compopt -o filenames
    elif [[ "${prev}" == "--startup-file" || \
            "${prev}" == "--handle-signals" || \
            "${prev}" == "--sysimage-native-code" || \
            "${prev}" == "--compiled-modules" || \
            "${prev}" == "--history-file" || \
            "${prev}" == "--warn-overwrite" || \
            "${prev}" == "--warn-scope" || \
            "${prev}" == "--warn-scope" || \
            "${prev}" == "--inline" ]]; then
        # These options complete yes/no
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -W "yes no" -- "${cur}")
    elif [[ "${prev}" == "--machine-file" ]]; then
        # --machinie-file completes files and directories
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -f -- "${cur}"; compgen -d -- "${cur}")
        compopt -o filenames
    elif [[ "${prev}" == "--banner" || \
            "${prev}" == "--color" || \
            "${prev}" == "--check-bounds" ]]; then
        # These options completes yes/no/auto
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -W "yes no auto" -- "${cur}")
    elif [[ "${prev}" == "--depwarn" ]]; then
        # --depwarn completes yes/no/error
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -W "yes no error" -- "${cur}")
    elif [[ "${prev}" == "--math-mode" ]]; then
        # --math-mode completes ieee/fast
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -W "ieee fast" -- "${cur}")
    elif [[ "${prev}" == "--code-coverage" || "${prev}" == "--track-allocation" ]]; then
        # --code-coverage completes none/user/all or a file (but file might not exist so can't give that option)
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -W "none user all" -- "${cur}")
    elif [[ "${prev}" == "--bug-report" ]]; then
        # --bug-report completes rr
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -W "rr" -- "${cur}")
    elif [[ "${cur}" =~ "-" ]]; then
        # remaining options have no special handling
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -W "${opts}" -- "${cur}")
    else
        # If not an option, complete *.jl files and directories (--load/-L also end up here)
        while IFS='' read -r l; do COMPREPLY+=("$l"); done < <(compgen -f -X '!*.jl' -- "${cur}"; compgen -d -- "${cur}")
        compopt -o filenames
    fi
    return 0
}

complete -F _julia julia
