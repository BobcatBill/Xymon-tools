#!/bin/bash
#########
#### Setup Section
########
cd `dirname $0`

#### ENV configuration
if [ -f /etc/redhat-release ]; then
	os="redhat"
elif [ "$(grep 'DISTRIB_RELEASE=' /etc/lsb-release| cut -d"=" -f2)" = "12.04" ]; then
	os="U12.04"
else
	os="Ubuntu"
fi

if [ $os = "redhat" ]; then
	CMD="/opt/MegaRAID/MegaCli/MegaCli64"
else 
	CMD="/usr/sbin/megacli"
fi

COLUMN=sm_raid
COLOR="red"
LOGFILELD="${BBTMP}/sm_raid_LD.log"
LOGFILEPD="${BBTMP}/sm_raid_PD.log"
DETAILSFILE="${BBTMP}/sm_raid_detail.log"
LOCATIONLINE="This message generated by `pwd`/`basename $0` on `hostname --fqdn`"

##########
##### Pre-flight Hobbit/Xymon Checks
##########
if test "$BBHOME" = ""; then
  echo "BBHOME is not set...exiting"
  exit 1
fi

#######################
######## Function Hardware Status
#######################
sudo ${CMD} -LDInfo -LAll -aAll >> $LOGFILELD

if [ 'grep "State" $LOGFILELD | grep "Optimal" = "Optimal"' ]; then
	COLOR="green"
	MSGLINE="All is well"
else
	COLOR="red"
	MSGLINE="A disk has failed"

fi
sudo ${CMD} -PDList -aALL >> $LOGFILEPD

if [ 'grep "S.M.A.R.T" $LOGFILEPD |grep "No" = "No"' ]; then
	COLOR="green"
else
	COLOR="red"
	MSGLINE="S.M.A.R.T errors detected"
fi

if [ 'grep "Firmware state" $LOGFILEPD |grep "Failed" = "Failed"' ]; then
         COLOR="green"
 else
         COLOR="red"
         MSGLINE="Failed Drive"
fi
####### Details Assembly section

egrep "((Slot Number)|(Firmware state)|(Drive\'s)|(PD)|(Size)|(Connected)|(Inquiry)|(Temperature)|(S.M.A.R.T)|^$)" $LOGFILEPD >> $DETAILSFILE
egrep "((Adaptor)|(Virtual)|(RAID)|(Size)|(State)|(Stripe)|(Number)|(Spin\ Up)|(Bad)|^$)" $LOGFILELD >> $DETAILSFILE

DETAILS=`cat $DETAILSFILE`
$BB $BBDISP "status $MACHINE.$COLUMN $COLOR `date`
${MSGLINE}

${DETAILS}

$LOCATIONLINE
"
rm $LOGFILEPD $LOGFILELD $DETAILSFILE 
rm MegaSAS.log
