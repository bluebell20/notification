#!/bin/bash
i=1
file_name=$1
ss_vip=$2
cat $1 |while read line
do 
  pid=`echo $line |awk '{print $1}'`
  cid=`echo $line |awk '{print $2}'`
  curl -s "http://${ss_vip}:8181/ContentDeleteReq?Provider_id=${pid}&Pcontent_id=${cid}" >> ${1}_del.result
  echo $i >> $1_del.result
  let i++
  sleep 0.3
done
