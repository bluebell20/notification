#!/bin/bash
##############################################################################
# ss_DB_hotbackup version 0.2 Author: Levi <levi@fonsview.com>               #
# Description: 执行此脚本，每天定时在备用SC备份SS_DB，主用SC备份点播         #
#              与直播list。                                                  #
##############################################################################

SCRIPT_DIR="/opt/fonsview/bin"
SCRIPT_NAME="ss_DB_hotbackup.sh"
COPY_NUM='3'
CRON="/etc/cron.d/ss_DB_hotbackup.cron"

add_to_cron()
{
    [ -e $CRON ] && rm -f $CRON
    sleep 1
    service crond restart
    sleep 1
    echo "SHELL=/bin/sh" > $CRON
    ha_state=`cat /opt/fonsview/NE/ss/data/proc/hastate | grep 'HA State' |  awk -F ':' '{print $2}'`
    ha_state=`echo $ha_state | sed s/[[:space:]]//g`
    
    if [ "$ha_state" == "ACTIVE" ]; then
        echo "0 4 * * * root $SCRIPT_DIR/$SCRIPT_NAME >/dev/null 2>&1" >> $CRON
    else
        echo "10 4 * * * root $SCRIPT_DIR/$SCRIPT_NAME >/dev/null 2>&1" >> $CRON
    fi
    service crond restart
}

generate_script()
{
    cat > $SCRIPT_DIR/$SCRIPT_NAME <<EOF
#!/bin/bash
today=\`date "+%Y%m%d"\`
back_dir="/opt/fonsview/data/ss/dbbackup"
ha_state=\`cat /opt/fonsview/NE/ss/data/proc/hastate | grep 'HA State' |  awk -F ':' '{print \$2}'\`
ha_state=\`echo \$ha_state | sed s/[[:space:]]//g\`
[ -d \$back_dir ] || mkdir -p \$back_dir

if [ "\$ha_state" != "ACTIVE" ]; then
    /opt/fonsview/bin/db_checkpoint -h /opt/fonsview/NE/ss/data/db -1
	/opt/fonsview/bin/db_hotbackup -h /opt/fonsview/NE/ss/data/db -b \$back_dir/db_back_\$today
else
    cat /opt/fonsview/NE/ss/data/proc/svdb/proglist > \$back_dir/proglist_\$today
    cat /opt/fonsview/NE/ss/data/proc/svdb/hlschanlist > \$back_dir/hlschanlist_\$today
    cat /opt/fonsview/NE/ss/data/proc/svdb/chanlist > \$back_dir/chanlist_\$today
fi

find \$back_dir -maxdepth 1 -mindepth 1 -type d -mtime +$COPY_NUM -exec rm -rf {} \;
find \$back_dir -maxdepth 1 -mindepth 1 -type f -mtime +$COPY_NUM -exec rm -rf {} \;
EOF
    chmod 755 $SCRIPT_DIR/$SCRIPT_NAME
}

del_cron()
{
    [ -e $CRON ] && rm -f $CRON
    sleep 1
    service crond restart
    sleep 1    
    rm -f $SCRIPT_DIR/$SCRIPT_NAME
}

while [ $1 ]; do
    case $1 in
        '--cron' | '-c' )
            add_to_cron
            generate_script
            exit
            ;;
        '--kill' | '-k' )
            del_cron
            exit
            ;;
    esac
done
