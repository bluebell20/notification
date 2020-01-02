#!/bin/bash
file_name=$1
now_time=`date '+%Y%m%d%H%M%S'`
cat $1 |while read line
do 
  pid=`echo $line |awk '{print $1}'`
  cid=`echo $line |awk '{print $2}'`
  cache=`cat /opt/fonsview/NE/ss/data/proc/cache/unicontentinfo/unicontentid/$pid@$cid`
  if [ ! -n "$cache" ];then
    sleep 0.1
  else
    echo $pid $cid >> need_del_$now_time
    sleep 0.1
  fi
  sleep 0.1 
done
