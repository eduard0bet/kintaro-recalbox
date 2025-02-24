#!/bin/sh
#                                      ▄▄= _╓_
#                                    ╓██▄▓██████▄_
#                                   j██████████████▄
#                                   ╫████████████▀"
#                                   ╫█████████╙
#                                 ,▄▓███████▓,
#                               ▄██████████████▄
#                              ª▀▀▀▀▀▀▀▀▀▀▀▀████H
#                         _,▄▄▓▓██████████▓▓████Ñ
#                     ,▄██████████████████████████▓▄_
#                  _▄█████████████████████████████████▄_
#                 ▄██████████████████████████████████████╓
#               ╓█████████████^╟██████████████████████████▓_
#              ╔█████████████  ▓████████████████████████████▄
#             ╔█████▀▀▀╙╙""`   ````""╙╙▀▀▀████████████╕'█████▄
#            ╓███,▄▄H                        └╙▀███████_▐█████╕
#            ██████▌  ▄▓▀▀▄╓          _╓▄▄▄▄╖_    ╙╙███▌ ██████_
#           ╫█████▌  ²╙  _ ╙▀       ▓▀╙"    '█H      _╙Ñ ▓█████▓
#          ▐██████      ▓██_ ,,        ▄█▌_  ``      ╟█▄|███████▒
#          ██████Ñ      `╙^_█╙╙▀▓▄    '███`          ╚███████████╕
#         ╟██████          `"    `                   [████████████
#        ╓██████▌     ▄▄▓█▓▀▀▀▀▀▀▓φ▄▄,_              [█████████████
#        ▓██████▌      ╟███▄╓,_____,,╠███▓▄▄▄        j██████████████
#       ║███████▌      '█████████████████▓           ▐███████████████╖
#      ╓█████████_      `████╙"]█▀╙"'╙██╜            ║█████████████████▄
#      ███████████_       ╙▓▄╓,╙`_,▄▓▀^              ╫█████████████```
#     ▓████████████_         '╙╙╙╙"                 _██████████████▌
#   _▓██████████████▄_     ª█      ,▄@            _▄████████████████H
#  »▓█████▀▀▀▀▀███████▌,    ╙▀▓▓▓▀▀╙`          _▄▓▀`╫████████▀╙▀▀▀▀██_
#              ╚█████▀╙╙▀▓▄,__           _,,▄▓▀▀"  ,██████▀"
# Copyright 2016 Kintaro Co.                                                                                                                                                     
# Copyright 2018 Michael Kirsch 
# Copyright 2023 Eduardo Betancourt


# Kintaro Controller service script
PYTHON="/usr/bin/python3"
SCRIPT="/opt/Kintaro/kintaro.py"
LOGFILE="/tmp/kintaro.log"

# Check if Python exists
if [ ! -x "$PYTHON" ]; then
    echo "Error: Python3 not found"
    exit 1
fi

# Check if the script exists
if [ ! -f "$SCRIPT" ]; then
    echo "Error: Kintaro script not found"
    exit 1
fi

check_status() {
    if pgrep -f "$SCRIPT" > /dev/null; then
        echo "Kintaro Controller is running"
        return 0
    else
        echo "Kintaro Controller is not running"
        return 1
    fi
}

start() {
    echo "Starting Kintaro Controller"
    if check_status > /dev/null; then
        echo "Already running"
    else
        $PYTHON $SCRIPT &
    fi
}

stop() {
    echo "Stopping Kintaro Controller"
    killall python3
    sleep 1
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 2
        start
        ;;
    status)
        check_status
        ;;
    log)
        if [ -f "$LOGFILE" ]; then
            tail -n 20 "$LOGFILE"
        else
            echo "Log file not found"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|log}"
        exit 1
        ;;
esac

exit 0