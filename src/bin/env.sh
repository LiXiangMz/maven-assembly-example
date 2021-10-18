#!/bin/bash
############ 应用按需修改的部分 ############
#应用名称，不指定则默认取最后一个jar文件名, 即springboot one jar打包后xxx.jar中xxx的部分
APP_NAME="@project.name@"
#指定应用端口号，不填则使用应用配置文件指定的端口
SERVER_PORT=
#指定JMX端口，不填则不开启JMX功能
SERVER_JMX_PORT=
#初始堆内存大小Xms，默认256m
HEAP_INIT=4g
#最大堆内存大小Xmx，默认256m
HEAP_MAX=4g
#年轻代最大堆内存大小Xmn，默认128m
HEAP_YOUNG_MAX=2g
#栈帧大小Xmn
X_S_S=256k
########################################
CURRENT_DATE=$(date +%Y%m%d)''$(date +%H%M%S)
#echo $CURRENT_DATE
#应用目录
APP_HOME=$PWD

# gc相关配置
JAVA_GC1="-XX:SurvivorRatio=8   -XX:+ExplicitGCInvokesConcurrent -XX:+PrintTenuringDistribution -XX:+UseCMSInitiatingOccupancyOnly -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled"
JAVA_GC2="-XX:+UseFastAccessorMethods -XX:CMSInitiatingOccupancyFraction=70 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC -Xloggc:$APP_HOME/logs/gc_$CURRENT_DATE.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$APP_HOME/temp/ -XX:OnOutOfMemoryError=$APP_HOME/bin/restart.sh"
JAVA_GC="$JAVA_GC1 $JAVA_GC2"
##########################

#如果未设置应用名，默认取最后一个jar文件名
if [ -z "$APP_NAME" ]; then
  APP_NAME=`ls|grep "jar$"|tail -n 1`
  APP_NAME=${APP_NAME%.jar}
fi

#通过APP_NAME取得应用进程pid
pid=`ps aux|grep "${APP_NAME}.jar"|grep -v grep|awk '{print $2}'`

#取得应用进程数量（0未启动、1启动，大于1说明程序重复起动）
pid_count=`echo $pid|wc -w`
