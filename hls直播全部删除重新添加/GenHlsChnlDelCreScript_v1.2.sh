#!/bin/sh

local_host=127.0.0.1			# local host ip
delete_file=DeleteAllHlsChnl.sh		# delete all hls channel script name
create_file=CreateAllHlsChnl.sh		# create all hls channel script name
del_create_chnl_interval=15000		# ms
chnl_interval=`expr $del_create_chnl_interval \* 1000`

if [ -f "$delete_file" ]; then
	rm -f $delete_file
fi
if [ -f "$create_file" ]; then
	rm -f $create_file
fi

sudo touch $delete_file
sudo chmod +x $delete_file
sudo touch $create_file
sudo chmod +x $create_file

echo chanid ProviderID ContentID TTL tvod_enable TSP shift_enable copies_hot main_m3u8_url

IFS_old=$IFS
IFS=$'\n'
for chanid in `cat /opt/fonsview/NE/ss/data/proc/svdb/hlschanlist`
do
	for line in `cat /opt/fonsview/NE/ss/data/proc/svdb/hlschanmap/$chanid`
	do
		tmp=`echo $line |grep ProviderID |awk -F ":" '{print $2}'|sed 's/[ \t]*$//g'`
		if [ -n "$tmp" ];then
        		provider_id="$tmp"
		fi
		tmp=`echo $line |grep ContentID|awk -F ":" '{print $2}'|sed 's/[ \t]*$//g'`
		if [ -n "$tmp" ];then
        		content_id="$tmp"
		fi
		tmp=`echo $line |grep TTL|awk -F ":" '{print $2}'|sed 's/[ \t]*$//g'`
		if [ -n "$tmp" ];then
        		rd_duration=$tmp
		fi
		tmp=`echo $line |grep tvod_enable|awk -F ":" '{print $2}'|awk -F "(" '{print $1}'`
		if [ -n "$tmp" ];then
        		rd_support=$tmp
		fi
		tmp=`echo $line |grep TSP|awk -F ":" '{print $2}'|sed 's/[ \t]*$//g'`
		if [ -n "$tmp" ];then
        		ts_duration=$(expr $tmp \* 60)
		fi
		tmp=`echo $line |grep shift_enable|awk -F ":" '{print $2}'|sed 's/[ \t]*$//g'`
		if [ -n "$tmp" ];then
        		ts_support=$tmp
		fi
		tmp=`echo $line |grep copies_hot|awk -F ":" '{print $2}'|sed 's/[ \t]*$//g'`
		if [ -n "$tmp" ];then
        		copies_hot=$tmp
		fi
		tmp=`echo $line |grep main_m3u8_url|sed 's/%/%%/g'|awk '{printf $2}'|sed 's/^.//'`
		if [ -n "$tmp" ];then
        		content_url=$tmp
		fi
	done
	echo ${chanid} ${provider_id} ${content_id} ${rd_duration} ${rd_support} ${ts_duration} ${ts_support} ${copies_hot} ${content_url}
	echo "sudo curl -gv 'http://${local_host}:8181/ContentDeleteReq?Provider_id=${provider_id}&Pcontent_id=${content_id}'" >> ${delete_file}
	echo "usleep $chnl_interval" >> ${delete_file}
	echo "sudo curl -gv 'http://${local_host}:8181/ContentDistributeReq?Provider_id=${provider_id}&Pcontent_id=${content_id}&ContentType=2&RdDuration=${rd_duration}&Rdsupport=${rd_support}&TsDuration=${ts_duration}&TSsupport=${ts_support}&UpdateHotFlag=${copies_hot}&ContentUrl=${content_url}'" >> ${create_file}
	echo "usleep $chnl_interval" >> ${create_file}
done
IFS=$IFS_old
echo "generate delete script ${delete_file} success"
echo "generate create script ${create_file} success"
