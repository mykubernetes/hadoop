# 一、手动执行平衡

1.1 获取命令帮助
```
 ./hdfs balancer --help
Usage: hdfs balancer
	[-policy <policy>]	the balancing policy: datanode or blockpool
	[-threshold <threshold>]	Percentage of disk capacity
	[-exclude [-f <hosts-file> | <comma-separated list of hosts>]]	Excludes the specified datanodes.
	[-include [-f <hosts-file> | <comma-separated list of hosts>]]	Includes only the specified datanodes.
	[-source [-f <hosts-file> | <comma-separated list of hosts>]]	Pick only the specified datanodes as source nodes.
	[-blockpools <comma-separated list of blockpool ids>]	The balancer will only run on blockpools included in this list.
	[-idleiterations <idleiterations>]	Number of consecutive idle iterations (-1 for Infinite) before exit.
	[-runDuringUpgrade]	Whether to run the balancer during an ongoing HDFS upgrade.This is usually not desired since it will not affect used space on over-utilized machines.

Generic options supported are
-conf <configuration file>     specify an application configuration file
-D <property=value>            use value for given property
-fs <file:///|hdfs://namenode:port> specify default filesystem URL to use, overrides 'fs.defaultFS' property from configurations.
-jt <local|resourcemanager:port>    specify a ResourceManager
-files <comma separated list of files>    specify comma separated files to be copied to the map reduce cluster
-libjars <comma separated list of jars>    specify comma separated jar files to include in the classpath.
-archives <comma separated list of archives>    specify comma separated archives to be unarchived on the compute machines.

The general command line syntax is
command [genericOptions] [commandOptions]
```

```
-threshold 5
集群平衡的条件，datanode间磁盘使用率差异的阈值，区间选择：0~100; Threshold参数为集群是否处于均衡状态设置了一个预期目标.
threshold 默认设置：10，参数取值范围：0-100，参数含义：判断集群是否平衡的目标参数，每一个 datanode 存储使用率和集群总存储使用率的差值都应该小于这个阀值 ，
理论上，该参数设置的越小，整个集群就越平衡，但是在线上环境中，hadoop集群在进行balance时，还在并发的进行数据的写入和删除，所以有可能无法到达设定的平衡参数值。
这个命令中-threshold 参数后面跟的是HDFS达到平衡状态的磁盘使用率偏差值。如果机器与机器之间磁盘使用率偏差小于10%，那么我们就认为HDFS集群已经达到了平衡的状态。

-policy datanode
默认为datanode，datanode级别的平衡策略

-exclude -f /tmp/ip1.txt
默认为空，指定该部分ip不参与balance， -f：指定输入为文件

-include -f /tmp/ip2.txt
默认为空，只允许该部分ip参与balance，-f：指定输入为文件

-idleiterations 5
迭代次数，默认为 5
```

参数调整：
- dfs.datanode.balance.bandwidthPerSec = 31457280 ，指定DataNode用于balancer的带宽为30MB，这个示情况而定，如果交换机性能好点的，完全可以设定为50MB，单位是Byte，如果机器的网卡和交换机的带宽有限，可以适当降低该速度，默认是1048576(1MB)，hdfs dfsadmin-setBalancerBandwidth 52428800可以通过命令设置
- -threshold：默认设置为10，参数取值范围0-100，参数含义：判断集群是否平衡的目标参数，每一个 datanode 存储使用率和集群总存储使用率的差值都应该小于这个阀值 ，理论上，该参数设置的越小，整个集群就越平衡，但是在线上环境中，hadoop集群在进行balance时，还在并发的进行数据的写入和删除，所以有可能无法到达设定的平衡参数值
- dfs.datanode.balance.max.concurrent.moves = 50，指定DataNode上同时用于balance待移动block的最大线程个数
- dfs.balancer.moverThreads：用于执行block移动的线程池大小，默认1000
- dfs.balancer.max-size-to-move：每次balance进行迭代的过程最大移动数据量，默认10737418240(10GB)
- dfs.balancer.getBlocks.size：获取block的数量，默认2147483648(2GB)
- dfs.balancer.getBlocks.minblock-size：用来平衡的最小block大小，默认10485760（10MB）
- dfs.datanode.max.transfer.threads：建议为16384)，指定用于在DataNode间传输block数据的最大线程数。


1.2 设置balance带宽
```
./hdfs dfsadmin -getBalancerBandwidth node01:50020
Balancer bandwidth is 10485760 bytes per second.
```

设置balance工具在运行中所能占用的带宽，需反复调试设置为合理值, 过大反而会造成MapReduce流程运行缓慢
```
hdfs dfsadmin -setBalancerBandwidth 104857600  
```

1.3 查询当前的集群数据节点
```
hdfs dfsadmin -printTopology
Rack: /default-rack
   192.168.102.69:50010 (node01)
   192.168.102.72:50010 (node04)
   192.168.31.115:50010 (node05)
```

1.4 使用命令平衡集群数据节点,指定节点均衡
```
hdfs balancer -threshold 5.0 -policy DataNode -include node01,node04,node05
```

```
# 启动数据平衡，默认阈值为 10%
hdfs balancer

# 默认相差值为10% 带宽速率为10M/s，过程信息会直接打印在客户端 ctrl+c即可中止
hdfs balancer -Ddfs.balancer.block-move.timeout=600000 

#可以手动设置相差值 一般相差值越小 需要平衡的时间就越长，//设置为20% 这个参数本身就是百分比 不用带%
hdfs balancer -threshold 20

#如果怕影响业务可以动态设置一下带宽再执行上述命令，1M/s
hdfs dfsadmin -setBalancerBandwidth 1048576

#或者直接带参运行，带宽为1M/s
hdfs balancer -Ddfs.datanode.balance.bandwidthPerSec=1048576 -Ddfs.balancer.block-move.timeout=600000
```

```
nohup hdfs balancer \ 
-D "dfs.balancer.movedWinWidth=300000000" \  
-D "dfs.datanode.balance.bandwidthPerSec=2000m" \ 
-threshold 5 > my-hadoop-balancer-v2021u1109.log &
```

1.5 也可以使用hadoop自带的脚本执行平衡命令
```
# vim start-balancer.sh
#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

bin=`dirname "${BASH_SOURCE-$0}"`
bin=`cd "$bin"; pwd`

DEFAULT_LIBEXEC_DIR="$bin"/../libexec
HADOOP_LIBEXEC_DIR=${HADOOP_LIBEXEC_DIR:-$DEFAULT_LIBEXEC_DIR}
. $HADOOP_LIBEXEC_DIR/hdfs-config.sh

# Start balancer daemon.

"$HADOOP_PREFIX"/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script "$bin"/hdfs start balancer $@
```

执行平衡命令
```
start-balancer.sh -threshold 10
```

停止数据均衡命令
```
stop-balancer.sh
```
- 正常情况下不用执行stop命令，程序会自动停止。均衡结束后需要将服务关掉，否则占用资源

在hdfs-site.xml文件中可以设置数据均衡占用的网络带宽限制
```
<property>
<name>dfs.balance.bandwidthPerSec</name>
<value>1048576</value>
<description> Specifies the maximum bandwidth that each datanode can utilize for the balancing purpose in term of the number of bytes per second. </description>
</property>
```

参考：
- https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#balancer

# 二、Hadoop单个节点的磁盘均衡

hadoop如果一个节点内有新增磁盘或者数据出现在磁盘上不均衡时，需要做磁盘均衡，就是将其他已经写入数据的磁盘均衡到新增加的磁盘上去，大概分为以下三个步骤，计划，执行，查询：

```
一般默认都开启了磁盘均衡，但是我这种状况特殊，公司给的初始磁盘大小不一样。。。我也没辙。。我只是试验下，我这种情况能否做数据的分散。
看下图，disk10已经91%了，剩余空间88G，但是从磁盘存储的数据来看，还是比较均衡的。。
```

```
# df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 252G     0  252G   0% /dev
tmpfs                    252G     0  252G   0% /dev/shm
tmpfs                    252G   59M  252G   1% /run
tmpfs                    252G     0  252G   0% /sys/fs/cgroup
/dev/mapper/centos-root   50G  1.8G   49G   4% /
/dev/mapper/centos-home  392G  106G  287G  85% /home
/dev/sda1               1014M  149M  866M  15% /boot
/dev/nvme2n1             932G  844G   88G  91% /dfs/data10
/dev/nvme0n1             932G  793G  139G  86% /dfs/data8
/dev/nvme1n1             932G  782G  150G  84% /dfs/data9
/dev/nvme3n1             932G  807G  125G  87% /dfs/data11
/dev/sdd                 2.2T  815G  1.4T  37% /dfs/data3
/dev/sde                 2.2T  799G  1.5T  36% /dfs/data4
/dev/sdh                 2.2T  729G  1.5T  33% /dfs/data7
/dev/sdc                 2.2T  868G  1.4T  39% /dfs/data2
/dev/sdg                 2.2T  864G  1.4T  39% /dfs/data6
/dev/sdb                 2.2T  869G  1.4T  39% /dfs/data1
/dev/sdf                 2.2T  868G  1.4T  39% /dfs/data5
tmpfs                     51G     0   51G   0% /run/user/1000
```

```
hdfs diskbalancer -plan <datanode_hostname>
hdfs diskbalancer -execute 'plan_json_path'
hdfs diskbalancer -query <datanode_hostname>
```

1、生成计划：
```
hdfs diskbalancer -plan cdh192-22
```

1.1 查看生成的计划 plan.json
```
[hadoop@cdh192-22 ~]$ hdfs dfs -cat /system/diskbalancer/2022-Nov-17-10-21-45/cdh192-22.plan.json
{"volumeSetPlans":[{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data10/","capacity":999716507648,"storageType":"DISK","used":518103326696,"reserved":0,"uuid":"DS-4ea78bac-85e4-4d7a-92f6-72d02502e30f","failed":false,"volumeDataDensity":-0.0534,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data7/","capacity":2399304445952,"storageType":"DISK","used":1115196706478,"reserved":0,"uuid":"DS-40172040-5a50-4f68-8201-208237f26d11","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":338470576696,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"},{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data11/","capacity":999716507648,"storageType":"DISK","used":464668232754,"reserved":0,"uuid":"DS-90f7fe25-1933-4167-8c14-2a9e2a143d0f","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data4/","capacity":2399304445952,"storageType":"DISK","used":1115196706478,"reserved":0,"uuid":"DS-b0cd02a7-2bf7-4457-abe9-14edd486d28e","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":259615596345,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"},{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data8/","capacity":999716507648,"storageType":"DISK","used":464668232754,"reserved":0,"uuid":"DS-176d5992-75bd-4767-9366-93df8a0fd159","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data3/","capacity":2399304445952,"storageType":"DISK","used":1115196706478,"reserved":0,"uuid":"DS-35e8ab71-a899-4ef7-be3f-d9c1f1c1561b","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":243296795330,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"},{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data9/","capacity":999716507648,"storageType":"DISK","used":464668232754,"reserved":0,"uuid":"DS-8b22a280-09ff-4f41-ae0a-55eaa62d300e","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data6/","capacity":2399304445952,"storageType":"DISK","used":1115196706478,"reserved":0,"uuid":"DS-5179da53-7b07-465e-b07e-b4a8795c85ce","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":190630379536,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"},{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data9/","capacity":999716507648,"storageType":"DISK","used":464668232754,"reserved":0,"uuid":"DS-8b22a280-09ff-4f41-ae0a-55eaa62d300e","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data2/","capacity":2399304445952,"storageType":"DISK","used":1107097449681,"reserved":0,"uuid":"DS-ad4ad5f7-4bc5-4cfd-80cb-cff8c6b837ca","failed":false,"volumeDataDensity":0.003400000000000014,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":181871783815,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"},{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data8/","capacity":999716507648,"storageType":"DISK","used":464668232754,"reserved":0,"uuid":"DS-176d5992-75bd-4767-9366-93df8a0fd159","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data5/","capacity":2399304445952,"storageType":"DISK","used":1115196706478,"reserved":0,"uuid":"DS-183b713c-f95d-45f5-8f1e-530ea8a15ec1","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":141152455299,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"},{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data11/","capacity":999716507648,"storageType":"DISK","used":464668232754,"reserved":0,"uuid":"DS-90f7fe25-1933-4167-8c14-2a9e2a143d0f","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data1/","capacity":2399304445952,"storageType":"DISK","used":1070758333399,"reserved":0,"uuid":"DS-ccc089fe-bb80-40d5-983e-fe678e7607b3","failed":false,"volumeDataDensity":0.018600000000000005,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":140740287938,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"},{"@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep","sourceVolume":{"path":"/dfs/data10/","capacity":999716507648,"storageType":"DISK","used":518103326696,"reserved":0,"uuid":"DS-4ea78bac-85e4-4d7a-92f6-72d02502e30f","failed":false,"volumeDataDensity":-0.0534,"skip":false,"transient":false,"readOnly":false},"destinationVolume":{"path":"/dfs/data5/","capacity":2399304445952,"storageType":"DISK","used":1115196706478,"reserved":0,"uuid":"DS-183b713c-f95d-45f5-8f1e-530ea8a15ec1","failed":false,"volumeDataDensity":9.999999999998899E-5,"skip":false,"transient":false,"readOnly":false},"idealStorage":0.4648,"bytesToMove":47840136002,"volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"}],"nodeName":"cdh192-22","nodeUUID":"13584e04-9fdd-468b-96da-59e6be03259b","port":9867,"timeStamp":1668651705345}
```

1.2 查看json格式化后的生成计划
```
{
    "volumeSetPlans":[
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data10/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":518103326696,
                "reserved":0,
                "uuid":"DS-4ea78bac-85e4-4d7a-92f6-72d02502e30f",
                "failed":false,
                "volumeDataDensity":-0.0534,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data7/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1115196706478,
                "reserved":0,
                "uuid":"DS-40172040-5a50-4f68-8201-208237f26d11",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":338470576696,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        },
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data11/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":464668232754,
                "reserved":0,
                "uuid":"DS-90f7fe25-1933-4167-8c14-2a9e2a143d0f",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data4/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1115196706478,
                "reserved":0,
                "uuid":"DS-b0cd02a7-2bf7-4457-abe9-14edd486d28e",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":259615596345,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        },
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data8/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":464668232754,
                "reserved":0,
                "uuid":"DS-176d5992-75bd-4767-9366-93df8a0fd159",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data3/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1115196706478,
                "reserved":0,
                "uuid":"DS-35e8ab71-a899-4ef7-be3f-d9c1f1c1561b",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":243296795330,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        },
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data9/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":464668232754,
                "reserved":0,
                "uuid":"DS-8b22a280-09ff-4f41-ae0a-55eaa62d300e",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data6/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1115196706478,
                "reserved":0,
                "uuid":"DS-5179da53-7b07-465e-b07e-b4a8795c85ce",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":190630379536,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        },
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data9/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":464668232754,
                "reserved":0,
                "uuid":"DS-8b22a280-09ff-4f41-ae0a-55eaa62d300e",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data2/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1107097449681,
                "reserved":0,
                "uuid":"DS-ad4ad5f7-4bc5-4cfd-80cb-cff8c6b837ca",
                "failed":false,
                "volumeDataDensity":0.003400000000000014,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":181871783815,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        },
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data8/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":464668232754,
                "reserved":0,
                "uuid":"DS-176d5992-75bd-4767-9366-93df8a0fd159",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data5/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1115196706478,
                "reserved":0,
                "uuid":"DS-183b713c-f95d-45f5-8f1e-530ea8a15ec1",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":141152455299,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        },
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data11/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":464668232754,
                "reserved":0,
                "uuid":"DS-90f7fe25-1933-4167-8c14-2a9e2a143d0f",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data1/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1070758333399,
                "reserved":0,
                "uuid":"DS-ccc089fe-bb80-40d5-983e-fe678e7607b3",
                "failed":false,
                "volumeDataDensity":0.018600000000000005,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":140740287938,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        },
        {
            "@class":"org.apache.hadoop.hdfs.server.diskbalancer.planner.MoveStep",
            "sourceVolume":{
                "path":"/dfs/data10/",
                "capacity":999716507648,
                "storageType":"DISK",
                "used":518103326696,
                "reserved":0,
                "uuid":"DS-4ea78bac-85e4-4d7a-92f6-72d02502e30f",
                "failed":false,
                "volumeDataDensity":-0.0534,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "destinationVolume":{
                "path":"/dfs/data5/",
                "capacity":2399304445952,
                "storageType":"DISK",
                "used":1115196706478,
                "reserved":0,
                "uuid":"DS-183b713c-f95d-45f5-8f1e-530ea8a15ec1",
                "failed":false,
                "volumeDataDensity":0.00009999999999998899,
                "skip":false,
                "transient":false,
                "readOnly":false
            },
            "idealStorage":0.4648,
            "bytesToMove":47840136002,
            "volumeSetID":"9bbee851-9964-4d91-8a61-41ae86901e37"
        }
    ],
    "nodeName":"cdh192-22",
    "nodeUUID":"13584e04-9fdd-468b-96da-59e6be03259b",
    "port":9867,
    "timeStamp":1668651705345
}
```

2.执行计划
```
hdfs diskbalancer -execute  /system/diskbalancer/2022-Nov-17-10-21-45/cdh192-22.plan.json
```

## 3.查看计划
```
hdfs diskbalancer -query cdh192-22
```

状态说明：
- PLAN_UNDER_PROGRESS 计划进行中
- PLAN_DONE 计划执行完成

执行一会，查看有些许的优化了，但是这样子显然不久就又会到达90%的阈值的：
```
# df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 252G     0  252G   0% /dev
tmpfs                    252G     0  252G   0% /dev/shm
tmpfs                    252G   59M  252G   1% /run
tmpfs                    252G     0  252G   0% /sys/fs/cgroup
/dev/mapper/centos-root   50G  1.8G   49G   4% /
/dev/mapper/centos-home  392G  106G  287G  85% /home
/dev/sda1               1014M  149M  866M  15% /boot
/dev/nvme2n1             932G  784G  148G  85% /dfs/data10
/dev/nvme0n1             932G  794G  139G  86% /dfs/data8
/dev/nvme1n1             932G  782G  150G  84% /dfs/data9
/dev/nvme3n1             932G  807G  125G  87% /dfs/data11
/dev/sdd                 2.2T  815G  1.4T  37% /dfs/data3
/dev/sde                 2.2T  799G  1.5T  36% /dfs/data4
/dev/sdh                 2.2T  789G  1.5T  36% /dfs/data7
/dev/sdc                 2.2T  867G  1.4T  39% /dfs/data2
/dev/sdg                 2.2T  865G  1.4T  39% /dfs/data6
/dev/sdb                 2.2T  868G  1.4T  39% /dfs/data1
/dev/sdf                 2.2T  867G  1.4T  39% /dfs/data5
tmpfs                     51G     0   51G   0% /run/user/1000
```

## Hadoop DataNode多目录磁盘配置

- 配置hdfs-site.xml

在配置文件中$HADOOP_HOME/etc/hadoop/hdfs-site.xml添加如下配置
```
<!-- dfs.namenode.name.dir是保存FsImage镜像的目录，作用是存放hadoop的名称节点namenode里的metadata-->
<property>
  <name>dfs.namenode.name.dir</name>
  <value>file:/opt/bigdata/hadoop/hadoop-3.3.4/data/namenode</value>
</property>
<!-- 存放HDFS文件系统数据文件的目录（存储Block），作用是存放hadoop的数据节点datanode里的多个数据块。 -->
<property>
    <name>dfs.datanode.data.dir</name>
    <value>/data1,/data2,/data3,/data4</value>
</property>

<!-- 设置数据存储策略，默认为轮询，现在的情况显然应该用“选择空间多的磁盘存”模式 -->
<property>
    <name>dfs.datanode.fsdataset.volume.choosing.policy</name>
    <value>org.apache.hadoop.hdfs.server.datanode.fsdataset.AvailableSpaceVolumeChoosingPolicy</value>
</property>

<!-- 默认值0.75。它的含义是数据块存储到可用空间多的卷上的概率，由此可见，这个值如果取0.5以下，对该策略而言是毫无意义的，一般就采用默认值。-->
<property>
    <name>dfs.datanode.available-space-volume-choosing-policy.balanced-space-preference-fraction</name>
    <value>0.75f</value>
</property>

<!-- 配置各个磁盘的均衡阈值的，默认为10G（10737418240），在此节点的所有数据存储的目录中，找一个占用最大的，找一个占用最小的，如果在两者之差在10G的范围内，那么块分配的方式是轮询。 -->
<property>
  <name>dfs.datanode.available-space-volume-choosing-policy.balanced-space-threshold</name>         
  <value>10737418240</value>
</property>
```

## 配置详解

- 1、 dfs.datanode.data.dir HDFS数据应该存储Block的地方。可以是逗号分隔的目录列表（典型的，每个目录在不同的磁盘）。这些目录被轮流使用，一个块存储在这个目录，下一个块存储在下一个目录，依次循环。每个块在同一个机器上仅存储一份。不存在的目录被忽略。必须创建文件夹，否则被视为不存在。
- 2、`dfs.datanode.fsdataset.volume.choosing.policy` 当我们往`HDFS`上写入新的数据块，`DataNode`将会使用`volume`选择策略来为这个块选择存储的地方。通过参数 `dfs.datanode.fsdataset.volume.choosing.policy` 来设置，这个参数目前支持两种磁盘选择策略
  - `round-robin`：循环(round-robin)策略将新块均匀分布在可用磁盘上。配置：`org.apache.hadoop.hdfs.server.datanode.fsdataset.RoundRobinVolumeChoosingPolicy`；实现类：RoundRobinVolumeChoosingPolicy.java
  - `available space`：可用空间优先方式,根据磁盘空间剩余量来选择磁盘存储数据块。配置：`org.apache.hadoop.hdfs.server.datanode.fsdataset.AvailableSpaceVolumeChoosingPolicy`；实现类：AvailableSpaceVolumeChoosingPolicy.java

  这两种方式的优缺点：
    - 采用轮询卷存储方式虽然能保证每块盘都能得到使用，但是在长期运行的集群中由于数据删除和磁盘热插拔等原因，可能造成磁盘空间的不均。
    - 所以最好将磁盘选择策略配置成第二种，根据磁盘空间剩余量来选择磁盘存储数据块，这样能保证节点磁盘数据量平衡IO压力被分散。

- 3、`dfs.datanode.available-space-volume-choosing-policy.balanced-space-preference-fraction`它的含义是数据块存储到可用空间多的卷上的概率，仅在`dfs.datanode.fsdataset.volume.choosing.policy`设置为 `org.apache.hadoop.hdfs.server.datanode.fsdataset.AvailableSpaceVolumeChoosingPolicy` 时使用。此设置控制将多少百分比的新块分配发送到可用磁盘空间比其他卷更多的卷。此设置应在 `0.0` - `1.0` 的范围内，但在实践中为 `0.5` - `1.0`，因为没有理由希望具有较少可用磁盘空间的卷接收更多块分配。
- 4、`dfs.datanode.available-space-volume-choosing-policy.balanced-space-threshold`配置各个磁盘的均衡阈值的，默认为`10G（10737418240）`，在此节点的所有数据存储的目录中，找一个占用最大的，找一个占用最小的，如果在两者之差在10G的范围内，那么块分配的方式是轮询。
  - 所有的 volumes 磁盘可用空间差距没有超过10G，那么这些磁盘得到的最大可用空间和最小可用空间差值就会很小，这时候就会使用轮询磁盘选择策略来存放副本。
  - 如果 volumes 磁盘可用空间相差大于10G，那么可用空间策略会将 volumes 配置中的磁盘按照一定的规则分为highAvailableVolumes 和 lowAvailableVolumes。



参考：
- https://hadoop.apache.org/docs/r3.0.0/hadoop-project-dist/hadoop-hdfs/HDFSDiskbalancer.html
- https://blog.csdn.net/qq_35745940/article/details/126439759
