#!/bin/bash

function isnum() {
a=$1
[ ! -z "${a##[0-9]*}" ] && a=U
[ -z "$a" ] && a=U
echo $a
}

function ucheck() {
if [[ "$1"   =~ U ]]
then
 echo "U"
else
 echo ""
fi
}

cd `dirname $0`
host=`hostname`
port=7199

javacmd="java  -classpath nagtomcat.jar com.groundworkopensource.tomcat.nagios.plugin.Shell  -s $host -p $port -m java.lang:type=GarbageCollector,name=ConcurrentMarkSweep -a "

v1=`$javacmd CollectionCount | awk -F= '{print $4}'` 
v1=`isnum $v1`

javacmd="java  -classpath nagtomcat.jar com.groundworkopensource.tomcat.nagios.plugin.Shell  -s $host -p $port -m java.lang:type=GarbageCollector,name=ConcurrentMarkSweep -a "
v2=`$javacmd CollectionTime | awk -F= '{print $4}'`
v2=`isnum $v2`

COLUMN=cass_javalang
COLOUR=green
[ "`ucheck "${v1}${v2}${v3}${v4}"`" = "U" ] && COLOUR=yellow

MACHINE=`echo $host | tr '.' ','`
$BB $BBDISP "status $MACHINE.$COLUMN $COLOUR `date`

GarbageCollector ConcurrentMarkSweep CollectionCount $v1
GarbageCollector ConcurrentMarkSweep CollectionTime $v2

This message generated by `pwd`/`basename $0` on `hostname --fqdn`

"

