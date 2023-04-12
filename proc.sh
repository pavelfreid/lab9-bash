#!/bin/bash

echo "PID  TTY      STAT     TIME     COMMAND"

for pid in /proc/*/; do
    pid=${pid//\/proc\//}
    if [[ ! $pid =~ [^0-9]+ ]]; then
        if [[ -f "/proc/$pid/stat" ]]; then
            tty=$(awk '{print $7}' "/proc/$pid/stat")
            if [[ $tty == "?" ]]; then
                tty=""
            fi
            stat=$(awk '{print $3}' "/proc/$pid/stat")
            time=$(($(awk '{print $14+$15}' "/proc/$pid/stat")/100))
            command=$(cat "/proc/$pid/cmdline" | tr '\0' ' ')
            echo "$pid  $tty      $stat     $time     $command"
        fi
    fi
done
