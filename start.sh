#!/bin/bash

# 设置钱包地址变量


if ! type numactl >/dev/null 2>&1; then
    echo "Install numactl"
    sudo apt install -y numactl
fi

# 获取NUMA节点的数量
NUMA_NODES=$(numactl -H |grep available |awk '{print $2}')

if [[ $NUMA_NODES ]]&&[[ $NUMA_NODES != 'NUMA' ]]; then
    PROCESSES=$NUMA_NODES
else
    PROCESSES=1
fi

COMMAND_BASE="./gpool --pubkey 3ucoQSjg6AVpSotpZRCoHV82v6A1hNyMe6kX8Ag36qG9 --no-pcie >> worker.log 2>&1"

# 启动进程的函数，绑定到指定的NUMA节点
start_process_numa() {
    local NUMA_NODE=$1
    local COMMAND="nohup numactl --cpunodebind=${NUMA_NODE} --membind=${NUMA_NODE} $COMMAND_BASE &"
    eval "$COMMAND"
}

start_process_normal() {
    local COMMAND="nohup $COMMAND_BASE &"
    eval "$COMMAND"
}

# 如果支持NUMA，使用numactl
start_process(){
    if [[ $NUMA_NODES ]]&&[[ $NUMA_NODES != 'NUMA' ]]; then
        echo "Use numactl"
        for (( i=0; i<$NUMA_NODES; i++ )); do
            start_process_numa $i
        done
    else
        start_process_normal
    fi
}

start_process

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sleep 5

while true; do
    num=`ps aux | grep -w gpool | grep -v grep |wc -l`
    if [ "${num}" -lt "$PROCESSES" ];then
        echo "Num of processes is less than $PROCESSES restart it ..."
        killall -9 gpool
        start_process
    else
        echo "Process is running"
    fi
    sleep 10
done
