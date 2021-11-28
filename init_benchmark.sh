#!/bin/sh
# chkconfig: 123 69 68
# description: benchmark init script

# Source function library.
. /etc/init.d/functions

start() {
    echo -n "Start benchmark"
    /bin/benchmark.sh &
}

stop() {
    kill -9 `pidof benchmark.sh`
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
       start
       ;;
    status)
       # code to check status of app comes here 
       # example: status program_name
       ;;
    *)
       echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0 
