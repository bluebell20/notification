#!/bin/bash

sleep_per20query=0.1
ssdir='/opt/fonsview/NE/ss'
ssbin=${ssdir}/bin
ssdata=${ssdir}/data
datadir='./data'

ss_status=`${ssbin}/status.sh app`
if [ ${ss_status}x !=  "started"x ]; then
	echo "ss is not running!!!";
	exit 1;
fi

ha_state=`cat /opt/fonsview/NE/ss/data/proc/hastate | grep 'HA State' |  awk -F ':' '{print $2}'`

ha_state=`echo $ha_state | sed s/[[:space:]]//g`

if [ "$ha_state" != "ACTIVE" ];then
echo "this not is ACTIVE"
exit -1

fi 

cat /opt/fonsview/NE/ss/data/proc/svdb/proglist > proglist.txt

if [ ! -e $datadir ]; then
	mkdir -p $datadir
else
	rm -f $datadir/*.txt
fi
	
num=0
while read line;
do 
	proginfo=`cat ${ssdata}/proc/svdb/progmap/$line`
	if [ $? -ne 0 ]; then
		continue;
	fi
	pid=`echo "$proginfo"|grep '^ProviderID:'|awk -F ':' '{print $2}'`
	cid=`echo "$proginfo"|grep '^ContentID:'|awk -F ':' '{print $2}'`
	storage=`echo "$proginfo"|grep ') S:'|grep '\[ ' 2> /dev/null|wc -l`
	if [ $storage -gt 0 ]; then
		seglist=`echo "$proginfo"|grep '0 ) S:'|awk -F '[: ]' '{print $4}'`
	else
		seglist=`echo "$proginfo"|grep ') S:'|awk -F')' '{print $2}' | awk -F '[: ]' '{print $3}'|xargs`
	fi
	location=`echo "$proginfo"|grep '0 ) S:'|sed 's/\[//g'|sed 's/\]//g'|awk '{print $9,$11}'`
	for loc in ${location};
	do 
		echo "$pid $cid $line $seglist" >> ${datadir}/${loc}.txt
	done
	((num=num+1))
	((mod=num%20))
	if [ $mod -eq 0 ]; then
		sleep $sleep_per20query
	fi
done < proglist.txt


