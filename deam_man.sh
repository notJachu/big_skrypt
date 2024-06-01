#!/bin/bash

# Author           : Jan Stąsiek ( s197741@student.pg.edu.pl)
# Created On       : May 2024
# Last Modified By : Jan Stąsiek ( s197741@student.pg.edu.pl)
# Last Modified On : May 2024
# Version          : 0.1
#
# Description      :    A simple bash script that allows user to display running deamons, close them in specified time
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


VERSION="0.1"


# Checking for dependecnies that are crucial for the script to work
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

# Function that gets running deamons
function get_running_deamons {
    ps -eo 'tty,pid,comm,pcpu,pmem' | grep ^? | awk '{print $2, $3, $4, $5}'
}


# Function that displays running deamons
function display_running {
    local tmp_file="/tmp/running_daemons.txt"
    get_running_deamons > "$tmp_file"
    deamons_array=()
    while IFS= read -r line; do
        deamons_array+=("$line")
    done < "$tmp_file"

    res=$(zenity --list --column=PID --column=Name --column=CPU --column=Memory\
    --text="Running deamons" --title="Deamons" --width=400 --height=300 \
    --separator=" " ${deamons_array[@]})
    rm "$tmp_file" # Cleanup temporary file

    if [ -n "$res" ]; then
        get_process_details $res
    fi
}


# Using at command to schedule closing of deamons
function schedule_closing {
    TIME=`zenity --entry --title "Closing time" --text "Enter time in minutes"`
    echo "kill  $1" | at now + $TIME minutes
}

# Using at command to schedule launching of deamons
function schedule_launch {
    TIME=`zenity --entry --title "Launch time" --text "Enter time in minutes"`
    echo "service $1 start" | at now + $TIME minutes
}

# Function that allows user to select deamons to be closed
function close_deamons {
    local tmp_file="/tmp/running_daemons.txt"
    get_running_deamons > "$tmp_file"
    deamons_array=()
    while IFS= read -r line; do
        deamons_array+=("no $line") # adding "no" fixes wierd zenity checkbox that must steal one column from data
    done < "$tmp_file"

    res=$(zenity --list --checklist --column=Selected --column=PID --column=Name --column=CPU --column=Memory\
    --text="Select deamons to be closed in 1 minute" --title="Deamons" --width=400 --height=300 \
    --separator=" " ${deamons_array[@]})
    rm "$tmp_file" # Cleanup temporary file

    if [ -n "$res" ]; then
        for pid in $res; do
            echo $pid
            schedule_closing $pid
        done
    fi

}

# Function that allows user to select deamons to be launched
function list_avaliable {
    res=`ls /etc/init.d/ | grep -v README | zenity --list --column=Name --text="Select deamon to start" --title="Deamons" --width=500 --height=600`
    if [ -n "$res" ]; then
        schedule_launch $res
    fi

}

# Function that displays start menu
function draw_start_menu {
    zenity --list --column=Action --column=Description --text="Select action" --title="Deamons" --width=500 --height=300 \
        "Display" "Display running deamons" \
        "Close deamons" "Close running deamons in specified time (may crash system)" \
        "List avaliable" "List avaliable deamons in the /etc/init.d/ directory" \

}

# Function that gets details of a process
function get_process_details {
    p_res=`ps -p $1 --no-headers -o pid,comm,pcpu,pmem,time`
    zenity --list --column=PID --column=Name --column=CPU --column=Memory --column=Time --text="Process details" --title="Details" --width=400 --height=300 $p_res
}

function main {
    check_dependencies

    while [ 1 -eq 1 ]; do
        res=`draw_start_menu`
        case "$res" in
            "Display")
                display_running < tmp.txt
                ;;
            "Close deamons")    
                close_deamons
                ;;
            "List avaliable")
                list_avaliable
                ;;
            *)  
                echo "Exiting"
                #echo $res
                exit 0
                break
                ;;
        esac
    done
}

function HELP {
    echo "Usage: $0 [-v]"
    echo "Options:"
    echo "  -v  Print version"
    echo "  -h  Print help"
    exit 0
}

while getopts "vh" opt; do
    case ${opt} in
        v )
            echo "$VERSION"
            exit 0
            ;;
        h )
            HELP
            ;;
    esac
done
shift $((OPTIND -1))
main
