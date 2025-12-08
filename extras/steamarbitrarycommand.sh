#!/usr/bin/env bash

# Example: Set launch options to /path/to/script %command% --run taskmgr.exe
i=1
w=999
r=999
for arg in "$@"
do
    if [ "$arg" == "waitforexitandrun" ]
    then
        w=$i
    fi
    ((i++))
    if [ "$arg" == "--run" ]
    then
        r=$i
    fi
done

if [ $w -le $# -a $r -le $# ]
then
    set -- "${@:1:$w}" "${@:$r}"
fi
"$@"
