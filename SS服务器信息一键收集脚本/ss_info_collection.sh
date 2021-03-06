#!/bin/bash
##############################################################################
# ss_info_collection version 0.1 Author: Levi <levi@fonsview.com>            #
##############################################################################

ssdir='/opt/fonsview/NE/ss'
ssbin=${ssdir}/bin
ssdata=${ssdir}/data
datadir='./info_collect'

info_colletc()
{
	echo "--------------------"
	echo $1
	$1
	echo
}

file_name=(
	"ss_info.log"
	"cpu.log"
	"top_cpu.log"
	"flow.log"
	"iostat.log"
	"netstat.log"
	"nic.log"
	"bond.log"
	)

ss_cmd=(
	"cat ${ssdata}/proc/mng/nodes"
	"cat ${ssdata}/proc/mng/nics"
	"cat ${ssdata}/proc/mng/version"
	"cat ${ssdata}/proc/sts/cluster"
	"cat ${ssdata}/proc/fsio/disks"
	"cat ${ssdata}/proc/ctx/mem_sts"
	"ip ro"
	"ip -6 ro"
	"ntpq -pn"
	)

system_cmd=(
	"lsb_release -a"
	"uptime"
	"ifconfig"
	"free -m"
	"cat /proc/meminfo"
	"df -h"
	"lsblk"
	)

ss_status=`${ssbin}/status.sh app`
if [ ${ss_status}x !=  "started"x ]; then
	echo "ss is not running!!!";
	exit 1;
fi

if [ ! -e $datadir ]; then
	mkdir -p $datadir
else
	rm -f $datadir/*.log
fi

if [ -f ${ssdata}/proc/hastate ];then
        info_colletc "cat ${ssdata}/proc/hastate" >> $datadir/${file_name[0]}
fi

for i in `seq 0 $((${#ss_cmd[*]}-1))`
do
	info_colletc "${ss_cmd[$i]}" >> $datadir/${file_name[0]}
done

for i in `seq 0 $((${#system_cmd[*]}-1))`
do
        info_colletc "${system_cmd[$i]}" >> $datadir/${file_name[0]}
done

echo "--------------------" >> $datadir/${file_name[0]}
echo "ls -l /core* 2>/dev/null |wc -l" >> $datadir/${file_name[0]}
ls -l /core* 2>/dev/null |wc -l >> $datadir/${file_name[0]}
echo >> $datadir/${file_name[0]}

sar -P ALL 1 10 > $datadir/${file_name[1]}
info_colletc "top -d 1 -n 5 -b" >> $datadir/${file_name[2]}
sar -n DEV 1 10 > $datadir/${file_name[3]}
iostat -mdx 1 10 > $datadir/${file_name[4]}
netstat -ant > $datadir/${file_name[5]}

NIC=`ip a |grep -E -v '^ |^$| lo:' |awk -F ":" '{print $2}' |sed s/[[:space:]]//g`
for i in $NIC
do
	info_colletc "ethtool $i" >> $datadir/${file_name[6]}
done

bond=`ip a |grep -E -v '^ |^$| lo:' |awk -F ":" '{print $2}' |sed s/[[:space:]]//g|grep bond`
if [ "$bond" ];then
	for i in $bond
	do
		info_colletc "cat /proc/net/bonding/$i" >> $datadir/${file_name[7]}
	done
fi

tar -czvf info.tar.gz info_collect >/dev/null
