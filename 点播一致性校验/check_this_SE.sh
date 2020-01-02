#!/bin/bash

sleep_per20contents=0.1
ssdir='/opt/fonsview/NE/ss'
ssbin=${ssdir}/bin
ssdata=${ssdir}/data
datadir='./data'

ss_status=`${ssbin}/status.sh app`
if [ ${ss_status}x !=  "started"x ]; then
        echo "ss is not running!!!";
        exit 1;
fi

nodeid=`cat ${ssdata}/proc/mng/nodes |grep "^\*[0-9]"|awk -F '[* ]' '{print $2}'`

if [ -e ${nodeid}.txt ]; then 
	echo "to process ${nodeid}.txt"
else
	echo "there is no data file for this node(${nodeid})"
	exit 1;
fi

if [ -e ${nodeid}_err.txt ]; then 
	rm -f ${nodeid}_err.txt
fi

number=0
#$pid $cid $line  $seglist
while read line;
do 
	n=-1
	for i in $line;
	do 
		((n=n+1))
		if [ $n -eq 0 ]; then 
			pid=$i;
			continue
		fi
		if [ $n -eq 1 ]; then 
			cid=$i
			continue
		fi
		if [ $n -eq 2 ]; then 
			contentid=$i
			continue
		fi
		if [ $n -eq 3 ];then 
			segid=$i
			secid=`cat ${ssdata}/proc/fsio/inode/${i}|head -1|awk -F ':| ' '{print $20}'`
			if [ ${secid}x == x ]; then
				echo "$pid $cid $contentid chanid $secid  segid_${i}_lost" >> ${nodeid}_err.txt
				break;
			fi
			if [ ${secid}x != ${contentid}x ]; then
				echo "$pid $cid $contentid chanid $secid  segid_${i}_mismatch" >> ${nodeid}_err.txt
				break;
			fi
		fi
	done
	((number=number+1))
	((mod=number%20))
	if [ $mod -eq 0 ]; then
		sleep $sleep_per20contents
	fi 
done < ${nodeid}.txt


