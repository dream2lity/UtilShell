#!/bin/bash

# 当前CPU使用情况
function cpu() {
        util=$(vmstat | awk '{if(NR == 3) print $13+$14}')
        iowait=$(vmstat | awk '{if(NR == 3) print $16}')
        echo "CPU"
        echo -e "\t 使用率: ${util}%,\t 等待磁盘IO响应使用率：${iowait}%"
}

# 当前内存使用情况
function memory() {
        total=$(free -m | awk '{if(NR == 2) printf "%.1f",$2/1024}')
        used=$(free -m | awk '{if(NR == 2) printf "%.1f",($2-$NF)/1024}')
        available=$(free -m | awk '{if(NR == 2) printf "%.1f",$NF/1024}')
        echo "内存"
        echo -e "\t 总大小: ${total}G,\t 已使用: ${used}G,\t 剩余: ${available}G"
}

# 当前磁盘使用情况
#function disk() {
disk() {
        echo "磁盘"
        fs=$(df -h | awk '/^\/dev/{print $1}')
        for i in $fs; do
                #mounted=$(df -h | awk -v fsname=$i '{if($1 == fsname) print $NF}')
                mounted=$(df -h | awk -v fsname=$i '$1 == fsname {print $NF}')
                size=$(df -h | awk -v fsname=$i '$1 == fsname {print $2}')
                used=$(df -h | awk -v fsname=$i '$1 == fsname {print $3}')
                used_percent=$(df -h | awk -v fsname=$i '$1 == fsname {print $5}')
                echo -e "\t 挂载点: $mounted,\t 总大小: $size,\t 已使用: $used,\t 使用率: $used_percent"
        done
}

# 当前TCP连接情况
tcp() {
        summary=$(netstat -antp | awk '(NR != 1 && NR != 2) {a[$6]++} END {for(i in a) printf i": "a[i]"\t"}')
        echo "TCP"
        echo -e "\t $summary"
}

# 占用CPU最多的进程 top10
max_cpu_program() {
        ps -eo pid,pcpu,pmem,args --sort=-pcpu | head -n 10
}

# 占用内存最多的进程 top10
max_mem_program() {
        ps -eo pid,pcpu,pmem,args --sort=-pmem | head -n 10
}

# 1秒内上传和下载的流量
flow_rate() {
        network="eth0"
        old_in=$(awk '/'$network'/{print $2}' /proc/net/dev)
        old_out=$(awk '/'$network'/{print $10}' /proc/net/dev)
        sleep 1
        new_in=$(awk '/'$network'/{print $2}' /proc/net/dev)
        new_out=$(awk '/'$network'/{print $10}' /proc/net/dev)
        in=$(printf "%.1f %s" "$((($new_in - $old_in) / 1024))" "KB/s")
        out=$(printf "%.1f %s" "$((($new_out - $old_out) / 1024))" "KB/s")
        echo "当前流量"
        echo -e "\t 下载: $in,\t 上传: $out"
}

cpu
memory
disk
tcp
#max_cpu_program
#max_mem_program
flow_rate
