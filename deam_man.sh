#!/bin/bash

function check_dependencies {
    MISSING_DEPS=0
    for dep in node zenity chrontab; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo "Error: $dep is not installed"
            MISSING_DEPS=1
        fi
    done
    if [ $MISSING_DEPS -eq 1 ]; then
        exit 1
    fi
}

function get_running_deamons {
    ps -eo 'tty,pid,comm' | grep ^? | awk '{print $2, $3}'
}

function schedule_closing {
    echo "kill  $1" | at now + $2
}

function main {
    get_running_deamons > tmp.txt
    check_dependencies
    zenity --info --text="Hello, world!"
}

main
