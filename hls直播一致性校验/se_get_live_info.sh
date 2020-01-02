#!/bin/bash
##############################################################################
# se_get_live_info version 0.2 Author: Levi <levi@fonsview.com>              #
##############################################################################


sleep_per20query=0.1
ssdir='/opt/fonsview/NE/ss'
ssbin=${ssdir}/bin
ssdata=${ssdir}/data
sedatadir='./se_data'
#scdatadir='./sc_data'
nodeid=`cat ${ssdata}/proc/mng/nodes |grep "^\*[0-9]"|awk -F '[* ]' '{print $2}'`

ss_status=`${ssbin}/status.sh app`
if [ ${ss_status}x !=  "started"x ]; then
	echo "ss is not running!!!";
	exit 1;
fi

cat /opt/fonsview/NE/ss/data/proc/rem_hls/hlschanlist > se_hlschanlist.txt

#if [ ! -e $scdatadir ]; then
#	echo "scdatadir not exsit!!!";
#	exit 1;
#fi
	
if [ ! -e $sedatadir ]; then
	mkdir -p $sedatadir
else
	rm -f $sedatadir/*.txt
fi
	
num=0
while read line;
do 
	hlschaninfo=`cat ${ssdata}/proc/rem_hls/hlschanmap/$line`
	if [ $? -ne 0 ]; then
		continue;
	fi
	pid=`echo "$hlschaninfo"|grep '^ProviderID'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
	cid=`echo "$hlschaninfo"|grep '^ContentID'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
	chanid=`echo "$hlschaninfo"|grep '^chanid'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
	echo "$pid $cid $chanid" >> ${sedatadir}/${nodeid}.txt
	((num=num+1))
	((mod=num%20))
	if [ $mod -eq 0 ]; then
		sleep $sleep_per20query
	fi
done < se_hlschanlist.txt

cat ${sedatadir}/${nodeid}.txt |sort -n > ${sedatadir}/${nodeid}_se_sort.txt
# diff $scdatadir/${nodeid}_sc_sort.txt $sedatadir/${nodeid}_se_sort.txt
diff ${nodeid}_sc_sort.txt $sedatadir/${nodeid}_se_sort.txt > ${nodeid}_diff.txt

if [ "$?" == 0 ];then
	echo ${nodeid} db correct. > ${nodeid}_diff.txt
fi
if [ -d /opt/fonsview/NE/ss/data/.hls_chan_se_info/ ];then
	file_num=`ls -l /opt/fonsview/NE/ss/data/.hls_chan_se_info/ |grep chsi_ |wc -l`
	live_num=`cat /opt/fonsview/NE/ss/data/proc/rem_hls/used |tail -1 |awk '{print $2}'`
	if [[ $file_num == $live_num ]];then
		echo ${nodeid} local data correct. >> ${nodeid}_diff.txt
	else
		echo ${nodeid} local data error. >> ${nodeid}_diff.txt
	fi
fi
