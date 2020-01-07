#!/bin/bash
##############################################################################
# sc_get_live_info version 0.3 Author: Levi <levi@fonsview.com>              #
##############################################################################

########## Login parameter ############
# 定义登录方式,1代表登陆方式都相同，2代表登陆方式不同启用单独的登陆文件
longin_mode=1

# longin_mode=1时使用：
user=""
passwd=''
su_passwd=''
port=""

# longin_mode=2时使用，脚本同路径编写host_info.txt;格式如下
# location ip port user password su_password
# 例：1-0-0-0 1.1.1.1 49721 fonsview FonsView!23+ hello123
# 使用如下命令可以快速生成前两列
# cat /opt/fonsview/NE/ss/data/proc/mng/nics |grep SESH |while read line;do location=`echo $line |awk '{print $1}'` ip=`echo $line |awk '{print $3}'|awk -F '(' '{print $1}'`; echo $location $ip ;done > host_info.txt


sleep_per20query=0.1
ssdir='/opt/fonsview/NE/ss'
ssbin=${ssdir}/bin
ssdata=${ssdir}/data
datadir='./sc_data'


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

cat /opt/fonsview/NE/ss/data/proc/svdb/hlschanlist > hlschanlist.txt
all_location=`cat /opt/fonsview/NE/ss/data/proc/mng/nics |grep 'SESH' |awk '{print $1}'`

if [ ! -e $datadir ]; then
	mkdir -p $datadir
else
	rm -f $datadir/*.txt
fi
	
num=0
while read line;
do 
	hlschaninfo=`cat ${ssdata}/proc/svdb/hlschanmap/$line`
	if [ $? -ne 0 ]; then
		continue;
	fi
	pid=`echo "$hlschaninfo"|grep '^ProviderID'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
	cid=`echo "$hlschaninfo"|grep '^ContentID'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
	chanid=`echo "$hlschaninfo"|grep '^chanid'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
	copies_hot=`echo "$hlschaninfo"|grep '^copies_hot'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
	if [[ $copies_hot -eq 1 ]]; then
		for i in $all_location;
			do 
				echo "$pid $cid $chanid" >> ${datadir}/${i}.txt
			done
	else
		copies_need=`echo "$hlschaninfo"|grep '^copies_need'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
		master_se=`echo "$hlschaninfo"|grep '^master_se'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
		backup_se=`echo "$hlschaninfo"|grep '^backup_se'|awk -F ':' '{print $2}'| sed s/[[:space:]]//g`
		if [[ $copies_need -eq 1 ]]; then
			echo "$pid $cid $chanid" >> ${datadir}/${master_se}.txt
		elif [[ $copies_need -eq 2 ]];then
			echo "$pid $cid $chanid" >> ${datadir}/${master_se}.txt
			echo "$pid $cid $chanid" >> ${datadir}/${backup_se}.txt
		fi	
	fi
	((num=num+1))
	((mod=num%20))
	if [ $mod -eq 0 ]; then
		sleep $sleep_per20query
	fi
done < hlschanlist.txt

for i in $all_location;
	do
		cat ${datadir}/${i}.txt |sort -n > ${datadir}/${i}_sc_sort.txt
		rm -rf ${datadir}/${i}.txt
	done

for i in $all_location;
	do
		ip_addr=`cat /opt/fonsview/NE/ss/data/proc/mng/nics |grep $i |awk '{print $3}'|awk -F '(' '{print $1}'`
		if [ $longin_mode == 2 ];then
			port=`cat host_info.txt|grep $i |awk '{print $3}'`
			user=`cat host_info.txt|grep $i |awk '{print $4}'`
			passwd=`cat host_info.txt|grep $i |awk '{print $5}'`
			su_passwd=`cat host_info.txt|grep $i |awk '{print $6}'`
		fi
		/usr/bin/expect << EOF
		set timeout 20
		spawn scp -P $port ${datadir}/${i}_sc_sort.txt se_get_live_info.sh $user@$ip_addr:/tmp
		expect { 
			"yes/no" { 
				send "yes\r" 
				exp_continue 
			}		 
			"assword:" { 
			send "$passwd\r" 
			}
		}
		expect eof
		
		spawn ssh -p $port $user@$ip_addr
		expect {
			"assword:" { 
			send "$passwd\r" 
			expect "]$ " 
			send "su\r" 
			expect "assword:" 
			send "$su_passwd\r" 
			}
		}
		expect "]# "  
		send "cd /tmp\r"
		expect "]# "
		send "sh se_get_live_info.sh\r"
		send "chown $user:$user ${i}_diff.txt\r"
		expect "]# "
		
		spawn scp -P $port $user@$ip_addr:/tmp/${i}_diff.txt .
		expect { 
			"assword:" { 
			send "$passwd\r" 
			}
		}
		expect eof		 
EOF
	done

echo
