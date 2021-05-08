#!/bin/bash
hp_process="lotus" #lotus-miner or lotus-worker
lp_process="bminer"

echo "outside USER:$1"

if [ -z$USER ] ;then
    USER=$1
else
    echo $USER
fi
ETH_MINER="/home/$USER/ethminer/bminer/"

time=$(date "+%Y-%m-%d %H:%M:%S")

check_gpu_process() {
    target=$1
    echo "checking gpu using of $target"	
    nvidia-smi pmon -c 5 | grep $target
    if [ $? -ne 0 ] ;then
        echo "not found $target gpu process"
        return 0
    else
        echo "found $target gpu process"
        return 1
    fi
}

check_process() {
    target=$1
    echo "checking if process $target running"
    ps -ef | grep target | grep -v grep
    if [ $? -ne 0 ] ;then
        echo "not found $target process"
        return 0
    else
        echo "found $target process"
        return 1
    fi    
}

echo "checking if any lotus process is using GPU..."
check_gpu_process $hp_process
if [ $? == 1 ] ;then
    echo "$time lotus is using GPU, kill any bminer process..."
    killall -9 $lp_process
else
    echo "not found any lotus GPU process, check if $lp_process running..."
    check_gpu_process $lp_process
    if [ $? == 0 ] ;then
        echo "$time launch bminer..."
        cd $ETH_MINER
        ./mine.sh &
    else
        echo "$time bminer already run, do nothing"
    fi
fi
