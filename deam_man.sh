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

function display_running {
    local tmp_file="/tmp/running_daemons.txt"
    get_running_deamons > "$tmp_file"
    deamons_array=()
    while IFS= read -r line; do
        deamons_array+=("$line")
    done < "$tmp_file"
    #printf "%s\n" "${deamons_array[@]}"
    # res=$(zenity --list --checklist --column=PID --column=Name --column=CPU --column=Memory \
    # --text="Running deamons" --title="Deamons" --width=400 --height=300 \
    # --separator=" " ${deamons_array[@]})

    res=$(zenity --list --column=PID --column=Name --column=CPU --column=Memory\
    --text="Running deamons" --title="Deamons" --width=400 --height=300 \
    --separator=" " ${deamons_array[@]})
    rm "$tmp_file" # Cleanup temporary file

    if [ -n "$res" ]; then
        get_process_details $res
    fi
}


function schedule_closing {
    TIME=`zenity --entry --title "Closing time" --text "Enter time in minutes"`
    echo "kill  $1" | at now + $TIME minutes
}

function schedule_launch {
    TIME=`zenity --entry --title "Launch time" --text "Enter time in minutes"`
    echo "service $1 start" | at now + $TIME minutes
}

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

function list_avaliable {
    res=`ls /etc/init.d/ | grep -v README | zenity --list --column=Name --text="Select deamon to start" --title="Deamons" --width=400 --height=300`
    if [ -n "$res" ]; then
        schedule_launch $res
    fi

}

function draw_start_menu {
    zenity --list --column=Action --column=Description --text="Select action" --title="Deamons" --width=400 --height=300 \
        "Display" "Display running deamons" \
        "Close all" "Close all running deamons in 1 minute (may crash system)" \
        "List avaliable" "List avaliable deamons in the /etc/init.d/ directory" \

}

function get_process_details {
    ps -p $1 -o pid,comm,pcpu,pmem,time | zenity --text-info --title="Process details" --width=400 --height=300
    # ps -p 37 -o pid,comm,pcpu,pmem,time
    # $1 is pid
}

function main {
    check_dependencies
    #get_running_deamons > tmp.txt

    #display_running
    #get_process_details 37

    #list_avaliable

    while [ 1 -eq 1 ]; do
        res=`draw_start_menu`
        case "$res" in
            "Display")
                display_running < tmp.txt
                ;;
            "Close all")
                close_deamons
                ;;
            "List avaliable")
                list_avaliable
                ;;
            *)  
                echo "Exiting"
                echo $res
                exit 0
                break
                ;;
        esac
    done
}

main
