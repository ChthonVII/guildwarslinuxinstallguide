#!/usr/bin/env bash

# wait 2 minutes for GW to definitely be started before doing the first check
sleep 120
while true
do
    # does Gw.exe process exist?
    gwpid=$(ps aux  |  grep -i Gw.exe  |  grep -v grep | awk '{print $2}')
    #echo "GW PID is" $gwpid
    if [ $gwpid ]
    then
        # is it a zombie process?
        pid_status=`head /proc/$gwpid/status | grep "State:*"`
        #echo "PID status is" $pid_status
        if [[ "$pid_status" =~ .*"zombie"*. ]]
        then
            #echo "GW.exe is a zombie. Killing it."
            kill $gwpid
            exit 0
        fi
    else
        #echo "Gw.exe isn't running. Exiting now."
        exit 0
    fi
    # wait 30 sec before checking again
    sleep 30
done
