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

3.查看计划
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

hdfs-site.xml 修改datanode写入策略，该配置默认是轮训，我们要改为以剩余空间考虑写入某块磁盘
```
<property>
    <name>dfs.datanode.fsdataset.volume.choosing.policy</name>
    <value>org.apache.hadoop.hdfs.server.datanode.fsdataset.AvailableSpaceVolumeChoosingPolicy</value>
</property>
```
以下参数是配置各个磁盘的均衡阈值的，默认为10G。  
在此节点的所有数据存储的目录中，找一个占用最大的，找一个占用最小的。  
如果在两者之差在10G的范围内，那么块分配的方式是轮询。如下为英文原文。  

This setting controls how much DN volumes are allowed to differ in terms of bytes of free disk space before they are considered imbalanced. If the free space of all the volumes are within this range of each other, the volumes will be considered balanced and block assignments will be done on a pure round robin basis.
```
<property>
    <name>dfs.datanode.available-space-volume-choosing-policy.balanced-space-threshold </name>
    <value>10737418240</value>
</property>
```
通过调整以上2个参数，应该就可以达到我们期望的效果了。  
即当每个目录的剩余空间的最大值和最小值差距在10G以内时，使用轮询写入，否则优先写入空间比较大的目录。  
