#!/bin/sh
# DD-WRT  BOOT_SCRIPT.SH /// 8-3-17
VER="2.01.21"
# marceloFZ (tecnicomarcelo@gmail.com)
#--------------------------------------------------------------------
echo "/// BOOT_SCRIPT.SH ..."
#--------------------------------------------------------------------
pastebin="/tmp/pastebin.sh"
msgfile="/tmp/msgfile"
loginprompt="/tmp/loginprompt"
#--------------------------------------------------------------------
rm="/bin/rm"
cat="/bin/cat"
#--------------------------------------------------------------------
msg (){
    $cat <<EOF > $msgfile
`$cat $loginprompt`
--------------------------------------------------
   IP: $WAN_IPADDR
 Host: $WAN_HOSTNAME
 DDNS: $DDNS_HOSTNAME
 $DATE_BAR
--------------------------------------------------
 `echo -e "$ERROR_BAR"`v$VER
EOF
}
espacios (){
    local j=1
    local tmp=""
    while [ $j -lt `expr $1 + 1` ]; do
        tmp=" $tmp"
        j=`expr $j + 1`
    done
    echo "$tmp"
}
error_bar (){
    if [  -n $1] || [ -n $2]; then
        local tmp="$1$2\n"
    else
        local tmp="$1\n $2\n"
    fi
    if [ $1 = $2 ] && [ -z $1]; then
        tmp=""
    else
        tmp="$tmp--------------------------------------------------\n "
    fi
    eval ERROR_BAR="'$tmp'"
}
f_date (){
    local tmpdate=$2
    # export TZ=ART3
    if [ -z $2]; then
        ntpclient 2.ar.pool.ntp.org
        sleep 2
        stopservice process_monitor
        sleep 2
        startservice process_monitor
        sleep 6
        tmpdate=`date +'%a, %d %b %Y %T -0300'` # tmpdate=`date -R`
    fi
    local tmp_DM=`echo $tmpdate | grep , | cut -d , -f 2 | cut -c 2-7`
    local tmp_HM=`echo $tmpdate | grep , | cut -d , -f 2 | cut -c 14-18`
    local tmp_H=`echo $tmpdate | grep , | cut -d , -f 2 | cut -c 14-15`
    local tmp_L=`expr $tmp_H % 24`
    local tmp_R=`expr 23 - $tmp_H`
    local tmp_Z=`date +'%Z'`
    local tmp_BAR="$tmp_DM | 0  $(espacios $tmp_L)(${tmp_HM})$(espacios $tmp_R)  24"
    local tmp=$1
    eval $tmp="'$tmpdate'"
    eval $tmp'_DM'='$tmp_DM'
    eval $tmp'_HM'='$tmp_HM'
    eval $tmp'_H'='$tmp_H'
    eval $tmp'_L'='$tmp_L'
    eval $tmp'_R'='$tmp_R'
    eval $tmp'_Z'='$tmp_Z'
    eval $tmp'_BAR'='$tmp_BAR'
}
#--------------------------------------------------------------------
WAN_IPADDR=`nvram get wan_ipaddr`
WAN_HOSTNAME=`nvram get wan_hostname`
DDNS_HOSTNAME=`nvram get ddns_hostname`
#--------------------------------------------------------------------
f_date DATE
#--------------------------------------------------------------------
boot_0=`nvram get boot_0`
if [ -z $boot_0 ] || [ $boot_0 = 0 ];
    then
    RECOVERY_BAR="" && RECOVERY_SUB=""
else
    RECOVERY_BAR="Recovery Mode: ${boot_0}x" && RECOVERY_SUB="--- RM ($boot_0)"
fi
#--------------------------------------------------------------------
SCHEDULE=`nvram get Schedule`
if [ -z $SCHEDULE ] || [ $SCHEDULE = 0 ];
    then
    nvram set Schedule=1
    subject="[Success] $RECOVERY_SUB"
    nvram set ScheduleDate="$DATE"
    error_bar "" "$RECOVERY_BAR"
else
    nvram set Schedule=`expr $SCHEDULE + 1`
    subject="[Failed] NSCH ($SCHEDULE) $RECOVERY_SUB"
    f_date DATESCH "`nvram get ScheduleDate`"
    error_bar "${DATESCH_DM} (${DATESCH_HM}        ${SCHEDULE}x        ${DATE_HM}) ${DATE_DM}" "$RECOVERY_BAR"
fi
nvram commit
#--------------------------------------------------------------------
msg
#--------------------------------------------------------------------
. $pastebin fwVY93Pb mailClient     # descarga el programa mailClient
key_user=UYAP1jDG                   # key del usuario.
#--------------------------------------------------------------------
. $mailClient $key_user marcelofz@10ar.com.ar "$subject" "$msgfile"
#--------------------------------------------------------------------
$rm -f $msgfile
#--------------------------------------------------------------------
echo "... BOOT_SCRIPT.SH ///"
