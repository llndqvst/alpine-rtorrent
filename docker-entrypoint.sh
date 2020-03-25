#!/bin/sh
check_session_directories() {
    local user; user="$(id -u)"
    local group; group="$(id -g)"
    RT_ERROR=false
    
    for d in $RTDIRS
    do
        if [ ! -w "$d" ]; then
            echo "rtorrent needs read/write access to $d"
            RT_ERROR=true
        fi
    done

    if $RT_ERROR; then
        exit 1
    fi

}

_main() {
    check_session_directories

    exec "$@"
}       

_main "$@"
