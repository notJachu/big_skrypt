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
    zenity --list --column=PID --column=Name --column=CPU --column=Memory\
    --text="Running deamons" --title="Deamons" --width=400 --height=300 \
    --separator=" " ${deamons_array[@]}
    
    rm "$tmp_file" # Cleanup temporary file
}


function schedule_closing {
    echo "kill  $1" | at now + $2
}

function close_deamons {
    while read line; do
        pid=$(echo $line | awk '{print $1}')
        schedule_closing $pid 1 minute
    done
}

function list_avaliable {
    ls /etc/init.d/ | grep -v README | zenity --list --column=Name --text="Select deamon to start" --title="Deamons" --width=400 --height=300
}

function draw_start_menu {
    zenity --list --column=Action --column=Description --text="Select action" --title="Deamons" --width=400 --height=300 \
        "Display" "Display running deamons" \
        "Close" "Close selected deamons"

}

function get_process_details {
    ps -p $1 -o pid,comm,pcpu,pmem,time | zenity --text-info --title="Process details" --width=400 --height=300
    # ps -p 37 -o pid,comm,pcpu,pmem,time
    # $1 is pid
}

function main {
    get_running_deamons > tmp.txt
    check_dependencies
    zenity --info --text="Hello, world!"

    display_running

    while [1 -eq 1]; do
        case $(draw_start_menu) in
            "Display")
                display_running < tmp.txt
                ;;
            "Close")
                close_deamons < tmp.txt
                ;;
            *)
                break
                ;;
        esac
    done
}

main
