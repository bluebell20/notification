#!/bin/bash
##############################################################################
# Modifie_kernel_para version 0.4 Author: Levi <levi@fonsview.com>           #
##############################################################################

# 判断操作系统版本
os_version=`lsb_release -a|grep Release|awk '{print $(NF)}'|awk -F '.' '{print $1}'`

mem_value=`expr $(cat /proc/meminfo |grep MemTotal |awk '{print $2}') / 8000000`
tcp_mem="$(expr 196608 \* $mem_value)	$(expr 262144 \* $mem_value)	$(expr 393216 \* $mem_value)"

declare -A sys_par
sys_par=(
	[net.core.netdev_budget]=2000
	[net.core.netdev_max_backlog]=262144
	[net.core.rmem_default]=1048576
	[net.core.rmem_max]=6291456
	[net.core.somaxconn]=65535
	[net.core.wmem_default]=1048576
	[net.core.wmem_max]=4194304
	[net.ipv4.ip_local_port_range]='1025	65535'
	[net.ipv4.tcp_abort_on_overflow]=0
	[net.ipv4.tcp_adv_win_scale]=2
	[net.ipv4.tcp_allowed_congestion_control]='cubic reno'
	[net.ipv4.tcp_app_win]=31
	[net.ipv4.tcp_available_congestion_control]='cubic reno'
	[net.ipv4.tcp_base_mss]=1400
	[net.ipv4.tcp_challenge_ack_limit]=1048576
	[net.ipv4.tcp_congestion_control]='cubic'
	[net.ipv4.tcp_dsack]=1
	[net.ipv4.tcp_ecn]=2
	[net.ipv4.tcp_fack]=1
	[net.ipv4.tcp_fin_timeout]=5
	[net.ipv4.tcp_frto]=2
	[net.ipv4.tcp_frto_response]=0
	[net.ipv4.tcp_keepalive_intvl]=2
	[net.ipv4.tcp_keepalive_probes]=3
	[net.ipv4.tcp_keepalive_time]=6
	[net.ipv4.tcp_limit_output_bytes]=262144
	[net.ipv4.tcp_low_latency]=1
	[net.ipv4.tcp_max_orphans]=1024
	[net.ipv4.tcp_max_ssthresh]=0
	[net.ipv4.tcp_max_syn_backlog]=204800
	[net.ipv4.tcp_max_tw_buckets]=5000
	[net.ipv4.tcp_mem]=${tcp_mem}
	[net.ipv4.tcp_min_tso_segs]=2
	[net.ipv4.tcp_moderate_rcvbuf]=1
	[net.ipv4.tcp_mtu_probing]=0
	[net.ipv4.tcp_no_metrics_save]=0
	[net.ipv4.tcp_orphan_retries]=1
	[net.ipv4.tcp_reordering]=3
	[net.ipv4.tcp_retrans_collapse]=1
	[net.ipv4.tcp_retries1]=2
	[net.ipv4.tcp_retries2]=2
	[net.ipv4.tcp_rfc1337]=0
	[net.ipv4.tcp_rmem]='4096	1048576	6291456'
	[net.ipv4.tcp_sack]=1
	[net.ipv4.tcp_slow_start_after_idle]=1
	[net.ipv4.tcp_stdurg]=0
	[net.ipv4.tcp_syn_retries]=2
	[net.ipv4.tcp_synack_retries]=2
	[net.ipv4.tcp_syncookies]=0
	[net.ipv4.tcp_thin_dupack]=0
	[net.ipv4.tcp_thin_linear_timeouts]=0
	[net.ipv4.tcp_timestamps]=1
	[net.ipv4.tcp_tso_win_divisor]=3
	[net.ipv4.tcp_tw_recycle]=0
	[net.ipv4.tcp_tw_reuse]=1
	[net.ipv4.tcp_window_scaling]=1
	[net.ipv4.tcp_wmem]='4096	1048576	4194304'
	[net.ipv4.tcp_workaround_signed_windows]=0
	[net.ipv4.udp_rmem_min]=4096
	[net.ipv4.udp_wmem_min]=4096
	[net.netfilter.nf_conntrack_acct]=0
	[net.netfilter.nf_conntrack_buckets]=65536
	[net.netfilter.nf_conntrack_checksum]=1
	[net.netfilter.nf_conntrack_events]=1
	[net.netfilter.nf_conntrack_events_retry_timeout]=5
	[net.netfilter.nf_conntrack_expect_max]=256
	[net.netfilter.nf_conntrack_generic_timeout]=6
	[net.netfilter.nf_conntrack_helper]=1
	[net.netfilter.nf_conntrack_icmp_timeout]=3
	[net.netfilter.nf_conntrack_log_invalid]=0
	[net.netfilter.nf_conntrack_max]=1048576
	[net.netfilter.nf_conntrack_tcp_be_liberal]=0
	[net.netfilter.nf_conntrack_tcp_loose]=1
	[net.netfilter.nf_conntrack_tcp_max_retrans]=2
	[net.netfilter.nf_conntrack_tcp_timeout_close]=5
	[net.netfilter.nf_conntrack_tcp_timeout_close_wait]=6
	[net.netfilter.nf_conntrack_tcp_timeout_established]=60
	[net.netfilter.nf_conntrack_tcp_timeout_fin_wait]=5
	[net.netfilter.nf_conntrack_tcp_timeout_last_ack]=3
	[net.netfilter.nf_conntrack_tcp_timeout_max_retrans]=3
	[net.netfilter.nf_conntrack_tcp_timeout_syn_recv]=3
	[net.netfilter.nf_conntrack_tcp_timeout_syn_sent]=3
	[net.netfilter.nf_conntrack_tcp_timeout_time_wait]=2
	[net.netfilter.nf_conntrack_tcp_timeout_unacknowledged]=3
	[net.netfilter.nf_conntrack_timestamp]=0
	[net.netfilter.nf_conntrack_udp_timeout]=3
	[net.netfilter.nf_conntrack_udp_timeout_stream]=3
	)

question='Do you want to change the parameter to the recommended value?(Yes/No)'

diff_values()
{
	if [ "$1" ];then
		if [ "$1" == "$2" ];then
			echo -e "$3" "current value is \"$1\",\033[32mpass.\033[0m"
		else
			echo -e "$3" "current value is \"$1\",\033[31msuggest modify.\033[0m" The recommended value is "\033[31m\"$2\".\033[0m"
		fi
	else
		echo -e There is no such parameter in the kernel "\033[31m\"$3\".\033[0m"
	fi
}


shutdown_irqbalance()
{
	if [ $os_version -lt 7 ]; then
		irq_status=$(service irqbalance status | grep running)
		if [ "x$irq_status" != "x" ]; then
			service irqbalance stop
		fi

		irq_on=$(chkconfig --list | grep irqbalance | grep on)
		if [ "x$irq_on" != "x" ]; then
			chkconfig --level 345 irqbalance off
		fi
	else
		systemctl status irqbalance.service 2>&1 > /dev/null
		irq_status=$(echo $?)
		if [ $irq_status == 0 ]; then
			systemctl stop irqbalance.service 
		fi
		
		irq_on=$(systemctl list-unit-files |grep irqbalance |awk '{print $2}')
		if [ $irq_on != "disabled" ]; then
			systemctl disable irqbalance.service
		fi
	fi	

}

ulimit_a()
{
	core_file_size=`ulimit -a |grep 'core file size'|awk '{print $NF}'`
	open_files=`ulimit -a |grep 'open files'|awk '{print $NF}'`

	if [ $os_version -lt 7 ]; then
		limit_file='/etc/security/limits.d/90-nproc.conf'
	else
		limit_file='/etc/security/limits.d/20-nproc.conf'
	fi
	
	cp -n $limit_file ~/$(echo ${limit_file}|awk -F '/' '{print $NF}').bak
	diff_values $core_file_size 0 "core_file_size"
	if [ $core_file_size != 0 ]; then
		read -p -e "$question" answer
		case $answer in
			'yes' | 'y' )
				sed -i '/^\*.*core/d' $limit_file
				sed -i '$a *          soft    core      0\
*          hard    core      0' $limit_file
				ulimit -c 0
				;;
			'no' | 'n' )
				continue
				;;
		esac
	fi
	diff_values $open_files 204800 "open_files"
	if [ $open_files != 204800 ]; then
		read -p -e "$question" answer
		case $answer in
			'yes' | 'y' )
				sed -i '/^\*.*nofile/d' $limit_file
				sed -i '$a *          soft    nofile    204800\
*          hard    nofile    204800' $limit_file
				ulimit -n 204800
				;;
			'no' | 'n' )
				continue
				;;
		esac
	fi
}

sysctl_a()
{
	cp -n /etc/sysctl.conf ~/sysctl.conf.bak
	for i in ${!sys_par[*]}
		do
		para_path=`echo $i|sed 's/\./\//g'`
		para_value=`cat /proc/sys/${para_path} 2>/dev/null`
		diff_values "$para_value" "${sys_par[$i]}" "$i"
		if [ "$para_value" ];then
			if [ "$para_value" != "${sys_par[$i]}" ];then
				read -p -e "$question" answer
				case $answer in
					'yes' | 'y' )
						if [ "$i" != "net.netfilter.nf_conntrack_buckets" ];then
							sed -i "/^${i}/d" /etc/sysctl.conf
							sed -i "\$a ${i} = ${sys_par[$i]}" /etc/sysctl.conf
						else
							sed -i "/^${i}/d" /etc/sysctl.conf
							echo "${sys_par[$i]}" > /sys/module/nf_conntrack/parameters/hashsize
							echo "options nf_conntrack hashsize=${sys_par[$i]}" > /etc/modprobe.d/nf_conntrack.conf
						fi
						;;
					'no' | 'n' )
						continue
						;;
				esac
			fi
		fi
		done
	sysctl -p > /dev/null
}

system_parameters()
{
	ulimit_a
	shutdown_irqbalance
	sysctl_a
}

system_parameters
