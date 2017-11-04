#!/bin/bash
#  50-geek - generate the system information

distro=$(lsb_release -s -d)
kernelVersion=$(uname -r)
date=`date`
load=`cat /proc/loadavg | awk '{print $1}'`
ip=`ifconfig $(route | grep default | awk '{ print $8 }') | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
rootUsage=`df -h / | awk '/\// {print $(NF-1)}'`
memoryUsage=`free | awk '/Mem/{printf("%.2f%"), $3/$2*100} /buffers\/cache/{printf(", buffers: %.2f%"), $4/($3+$4)*100}'`
swapUsage=`free -m | awk '/Swap/ { printf("%3.1f%%", "exit !$2;$3/$2*100") }'`
users=`users | wc -w`
processes=`ps aux | wc -l`
time=`uptime | grep -ohe 'up .*' | sed 's/,/\ hours/g' | awk '{ printf $2" "$3 }'`

[ -f /etc/motd.head ] && cat /etc/motd.head || true
printf "\n"
printf "Welcome on %s (%s %s %s)\n" "${distro}" "$(uname -o)" "${kernelVersion}" "$(uname -m)"
printf "\n"
printf "System information as of: %s\n" "$date"
printf "\n"
printf "System load:\t%s\t\tIP Address:\t%s %s\n" $load $ip
printf "Memory usage:\t%s\t\tSystem uptime:\t%s\n" "$memoryUsage" "$time"
printf "Usage on /:\t%s\t\tSwap usage:\t%s\n" $rootUsage $swapUsage
printf "Local Users:\t%s\t\tProcesses:\t%s\n" $users $processes

printf "\n"
