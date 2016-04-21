#!/usr/bin/env bash

prok_main() {
    local pids
    local ps_mods=""
    local pgrep_params

    pgrep_params="$(gen_pgrep_params)"

    if [ -z "$PATTERN" ]; then
        # word splitting in $pgrep_params is intended
        # shellcheck disable=SC2086
        pids="$(pgrep $pgrep_params)"
    else
        # word splitting in $pgrep_params is intended
        # shellcheck disable=SC2086
        pids="$(pgrep $pgrep_params "$PATTERN")"
    fi

    pids="$(echo "$pids" | grep -v "$$")"

    if [ -z "$pids" ]; then
        echo "No processes found"
        exit
    fi

    pids="$(echo "$pids"| tr '\n' ' ')"

    if [ -n "$FOREST" ]; then
        local temp_pids=""

        for pid in $pids
        do
            temp_pids+="$(proctree "$pid")"
        done

        pids="$temp_pids"
    fi

    if [ -n "$PS_U" ]; then
        ps_mods+="u"
    fi

    if [[ -n "$FOREST" && "$(uname)" == "Linux" ]]; then
        ps_mods+="f"
    fi

    # stackoverflow copypaste. It's a pity you're seeing this.
    pids="${pids%"${pids##*[![:space:]]}"}"

    if [ -n "$ps_mods" ]; then
        ps "$ps_mods" -p "$pids"
    else
        ps -p "$pids"
    fi

    if [ -n "$KILL_THEM_ALL" ]; then
        echo -n "Kill each of these processes"

        if [ -n "$FOREST" ]; then
            echo -n "(whole tree)"
        fi

        echo "? (y/n)"

        read -r KILL_THEM_ALL

        if [[ "$KILL_THEM_ALL" = "y" ||  "$KILL_THEM_ALL" = "yes" ]]; then
            # word splitting is intended
            # shellcheck disable=SC2086
            kill $pids

            echo "Killed"
        else
            echo "Abort"
        fi
    fi
}

gen_pgrep_params() {
    if [ -n "$ONLY_MY" ]; then
        MATCH_UID="$(id -u)"
    elif [ -n "$MATCH_USERNAME" ]; then
        MATCH_UID="$(id -u "$MATCH_USERNAME")"
    fi

    if [ -n "$MATCH_UID" ]; then
        echo -n " -u $MATCH_UID"
    fi

    if [ -z "$ONLY_PROCNAME" ]; then
        echo -n " -f"
    fi
}

# looks for all pid parents. Couldn't find a better way
proctree () {
    proc="$1"
    while [ ! "$proc" -eq 1 ]; do
        echo -n "${proc} "
        proc="$(ps -p "$proc" -o ppid= | tr -d '[:space:]')"
    done
}

usage() {
    echo "Prok: easy process grep with ps output"
    echo
    echo "Usage: prok [--user <USERNAME>] [--uid <UID>] [-fmpu] [<PATTERN>]"
    echo
    echo "Parameters:"
    echo "    -f --forest         print parents of all matched PID's."
    echo "                            On linux prints with 'ps f'"
    echo "    -m --my             match only processes of current user"
    echo "    -p --procname       match only process name, not full command line"
    echo "    -u                  print output in 'ps u' style"
    echo "    --user USERNAME     match only processes of USERNAME"
    echo "    --uid UID           match only processes of UID(numeric)"
    echo "    --kill              ask to kill all matched processes."
    echo "                            Be cautious with -f option, it'll bring whole forest down"
    echo
}

FOREST=""
ONLY_MY=""
ONLY_PROCNAME=""
MATCH_UID=""
MATCH_USERNAME=""
PATTERN=""
PS_U=""
KILL_THEM_ALL=""

combined_opts() {
    while getopts "hfmpu" opt; do
      case $opt in
        h) usage; exit;;
        f) FOREST="1";;
        m) ONLY_MY="1";;
        p) ONLY_PROCNAME="1";;
        u) PS_U="1";;
      esac
    done
}

# for single and long opts
while [ $# -gt 0 ]; do
    case "$1" in
        (-h|--help) usage; exit; ;;
        (-f|--forest) FOREST="1"; shift; ;;
        (-m|--my) ONLY_MY="1"; shift; ;;
        (-p|--procname) ONLY_PROCNAME="1"; shift; ;;
        (-u) PS_U="1"; shift; ;;
        (--uid) MATCH_UID="$2"; shift 2; ;;
        (--user) MATCH_USERNAME="$2"; shift 2; ;;
        (--kill) KILL_THEM_ALL="1"; shift; ;;
        (--) shift; PATTERN="$1"; break; ;;
        (-*) combined_opts "$1"; shift; ;;
        (*)  PATTERN="$1"; break; ;;
    esac
done

prok_main
