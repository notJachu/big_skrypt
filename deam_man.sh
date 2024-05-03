#!/bin/bash

function check_dependencies {
    MISSING_DEPS=0
    for dep in at zenity; do
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
    ps -eo 'tty,pid,comm,pcpu,pmem' | grep ^? | awk '{print $2, $3, $4, $5}'
}

function schedule_closing {
    echo "kill  $1" | at now + $2
}

function display_running {
    get_running_deamons | zenity --list --column=PID --column=Name --column=CPU --column=Memory --checklist --separator=" " --text="Select deamons to close" --title="Deamons" --width=400 --height=300
}

function main {
    get_running_deamons > tmp.txt
    check_dependencies
    zenity --info --text="Hello, world!"
}

main
