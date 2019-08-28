#!/bin/bash
#This script is in use of check meta system simply.
usage="`basename $0`
hbse | check the hbase status
zk   | check the zookeeper status
hdfs | check the hdfs status
"
#hdfs_check begin
date=`date +%Y%m%d`
date1=`date +%Y%m%d -d "-1 day"`
zk_conf="/home/hadoop/zookeeper/conf/zoo.cfg"
region_conf="/home/hadoop/hbase/conf/regionservers"
cmd_dfs="/home/hadoop/hdfs/bin/hdfs dfsadmin -report"
cmd_zk="/home/hadoop/zookeeper/bin/zkServer.sh status"
cmd_hbase1="echo 'status' |/home/hadoop/hbase/bin/hbase shell" 
cmd_hbase2="/home/hadoop/hbase/bin/hbase hbck"
dn_num=`cat /home/hadoop/hdfs/conf/slaves  | wc -l`
zk_num=`cat $zk_conf | grep server | wc -l`
dfs_out="/tmp/${date}_dfsreport.txt"
zk_out="/tmp/${date}_zk.txt"
hbase_out="/tmp/${date}_hbase.txt"
max=0
min=100
j=0
declare -a nodes=`cat /home/hadoop/hdfs/conf/slaves | tr "\n" " "`
declare -a zk_nodes=`cat $zk_conf | grep server | awk -F "[=:]" '{print $2}'`
#hdfs_check begin
function dfs_check() {

	if [ -f "/tmp/${date1}_dfsreport.txt" ];then
		echo "rm -f /tmp/${date1}_dfsreport.txt"
		rm -f /tmp/${date1}_dfsreport.txt
	fi 

	if [ -f $dfs_out ];then
		:
	else
		su - hadoop -c "$cmd_dfs" > $dfs_out
		if [ $? -ne 0 ];then
			echo "hdfs report execute failed"
			exit
		fi
	fi
	live_node=`grep total $dfs_out |awk   '{print $3}'`
	dead_node=$((dn_num - live_node))
	dfs_total=`grep "Present Capacity" $dfs_out | awk -F "[ ()]" '{print $5,$6}'`
	dfs_used=`head $dfs_out | grep "DFS Used:" | awk -F "[ ()]" '{print $5,$6}'`
	dfs_used_per=`head $dfs_out | grep "DFS Used%" | awk -F "[ %]" '{print $4}'`
	dfs_remaining=`head $dfs_out | grep "DFS Remaining" |awk -F "[ ()]" '{print $5,$6}'`
	block_corrupt=`head $dfs_out | grep "corrupt" | awk '{print $5}'`
	block_miss=`head $dfs_out | grep "Missing" | awk '{print $3}'`
	printf "\n\e[32mdatanode节点总数：\e[0m\t\e[31m%12d\e[0m\n\e[32m活跃节点数量：\e[0m\t\e[31m%20d\e[0m\n\e[32mdead节点数量：\e[0m\t\e[31m%20d\e[0m\n\e[32mDFS总容量：\e[0m\e[31m%32s\e[0m\n\e[32m已使用空间：\e[0m\e[31m%30s\e[0m\n\e[32mDFS已用空间使用率：\e[0m\e[31m%20.2f%%\e[0m\n\e[32mDFS剩余使用空间：\e[0m\e[31m%26s\e[0m\n\e[32m损坏的block数量：\e[0m\e[31m%19s\e[0m\n\e[32m丢失的block数量：\e[0m\e[31m%19s\e[0m\n\n" $dn_num $live_node $dead_node "$dfs_total" "$dfs_used" $dfs_used_per "$dfs_remaining" "$block_corrupt" "$block_miss"

	printf "\e[32m%-20s%31s\e[0m\n" "节点名称" "已用空间"
	declare -a spase
	for i in $nodes
		do
			remain=`grep -A6 $i $dfs_out | tail -1 | awk -F: '{print $2}'`
			remain1=`echo ${remain%\%*}`
			printf "\e[32m%-20s\e[0m\e[31m%20s\e[0m\n" $i $remain
			spase[$j]=$remain1
			let j++
		done

	for x in ${spase[@]}
		do
			status1=`echo "$max < $x" | bc`
			if [ $status1 -eq 1 ];then
				max=$x
			else
				max=$max
			fi
			status2=`echo "$min > $x" | bc`
			if [ $status2 -eq 1 ];then
				min=$x
			else
				min=$min
			fi
		done
	sub=`echo "$max - $min" | bc`
	status3=`awk -v num1="$sub" -v num2=10.0 'BEGIN{print(num1>num2)?"0":"1"}'`
	echo 
	if [ $status3 -eq 0 ];then
		printf "\e[32m最大节点空间使用率:\e[0m\t\e[31m%15.2f%%\e[0m\n\e[32m最小节点空间使用率:\e[0m\t\e[31m%15.2f%%\e[0m\n\e[32m最大最小空间使用率差值为\e[31m%.2f%%\e[0m\e[32m,大于\e[0m\e[31m10%%\e[0m\e[32m，需要执行start-balancer.\e[0m\n" $max $min $sub
	else
		printf "\e[32m最大节点空间使用率:\e[0m\t\e[31m%15.2f%%\e[0m\n\e[32m最小节点空间使用率:\e[0m\t\e[31m%15.2f%%\e[0m\n\e[32m最大最小空间使用率差值为\e[31m%.2f%%\e[0m\e[32m,小于\e[0m\e[31m10%%\e[0m\e[32m，不需要执行start-balancer.\e[0m\n" $max $min $sub
fi
	}

#hdfs_check end

#zookeeper_check begin
function zk_check() {

	if [ -f "/tmp/${date1}_zk.txt" ];then
		echo "rm -f /tmp/${date1}_zk.txt"
    	rm -f /tmp/${date1}_zk.txt
	fi
	
	if [ -f $zk_out ];then
    	cat $zk_out
		exit
	else
    	for i in $zk_nodes
    	do
        	zk_status=`su hadoop -c "ssh $i '$cmd_zk 2>/dev/null'"`
        	printf "\e[32mzk节点%-20s\e[0m%s\n" $i "$zk_status" | tee -a $zk_out
    	done
	fi
	zk_live=`egrep 'leader|follower' $zk_out | wc -l`
	printf "\e[32mzk节点总数：\e[0m\e[31m%16d\e[0m\n\e[32m活跃节点总数：\e[0m\e[31m%14d\e[0m\n\n" $zk_num $zk_live | tee -a $zk_out		
	}

#zk_ckeck end

#hbase_check bebin
function hbase_check() {
	
	if [ -f "/tmp/${date1}_hbase.txt" ];then
		echo "rm -f /tmp/${date1}_hbase.txt"
    	rm -f /tmp/${date1}_hbase.txt
	fi

	if [ -f $hbase_out ];then
		:
	else
		echo "Please wait..."
		su - hadoop -c "$cmd_hbase1 2>/dev/null" >>$hbase_out
		echo -e "\n\n" >>$hbase_out
		su - hadoop -c "$cmd_hbase2 2>/dev/null" >>$hbase_out
		echo -e "\n\n" >>$hbase_out
	fi
	total_region=`grep -A1 status $hbase_out | tail -1 |awk '{print $1}'`
	dead_region=`grep -A1 status $hbase_out | tail -1 |awk '{print $3}'`
	printf "\e[32mregionserver节点总数：\e[0m\e[31m%5d\e[0m\n\e[32mDead节点数量：\e[0m\e[31m%13d\e[0m\n" $total_region $dead_region
	hbck_status=`grep "Status: OK" $hbase_out`
	if [ $? -ne 0 ];then
		hbck_status="Status：INCONSISTENT"
	else
		hbck_status=$hbck_status
	fi
	printf "\e[32m集群一致性检查：\e[0m\e[31m%20s\e[0m\n\n" "$hbck_status"
	}
case "$1" in
    hdfs)
    dfs_check
    ;;
	zk)
	zk_check
	;;
	hbase)
	hbase_check
	;;
    *)
    echo "usage: $usage"
	exit
esac

