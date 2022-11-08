# 1、纠删码原理
 
HDFS默认情况下，一个文件有3个副本，这样提高了数据的可靠性，但也带来了2倍的冗余开销。Hadoop3.x引入了纠删码，采用计算的方式，可以节省约50％左右的存储空间。


## 1.2、纠删码操作相关的命令
```
[atguigu@hadoop102 hadoop-3.1.3]$ hdfs ec
Usage: bin/hdfs ec [COMMAND]
          [-listPolicies]
          [-addPolicies -policyFile <file>]
          [-getPolicy -path <path>]
          [-removePolicy -policy <policy>]
          [-setPolicy -path <path> [-policy <policy>] [-replicate]]
          [-unsetPolicy -path <path>]
          [-listCodecs]
          [-enablePolicy -policy <policy>]
          [-disablePolicy -policy <policy>]
          [-help <command-name>].
 ```
 
## 1.3、查看当前支持的纠删码策略
```
[atguigu@hadoop102 hadoop-3.1.3] hdfs ec -listPolicies

Erasure Coding Policies:
ErasureCodingPolicy=[Name=RS-10-4-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=10, numParityUnits=4]], CellSize=1048576, Id=5], State=DISABLED
ErasureCodingPolicy=[Name=RS-3-2-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=3, numParityUnits=2]], CellSize=1048576, Id=2], State=DISABLED
ErasureCodingPolicy=[Name=RS-6-3-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=1], State=ENABLED
ErasureCodingPolicy=[Name=RS-LEGACY-6-3-1024k, Schema=[ECSchema=[Codec=rs-legacy, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=3], State=DISABLED
ErasureCodingPolicy=[Name=XOR-2-1-1024k, Schema=[ECSchema=[Codec=xor, numDataUnits=2, numParityUnits=1]], CellSize=1048576, Id=4], State=DISABLED
```

## 1.4、纠删码策略解释:

### 目前hadoop-3.1 共支持5 种纠删码策略，分别是：

- RS-10-4-1024k：
```
使用RS 编码，每10 个数据单元（cell），生成4 个校验单元，共14 个单元，也就是说：这14 个单元中，只要有任意的10 个单元存在（不管是数据单元还是校验单元，只要总数=10），就可以得到原始数据。每个单元的大小是1024k=10241024=1048576。
存储的空间冗余率为（10+4）/10 = 1.4
```

- RS-3-2-1024k：
```
使用RS 编码，每3 个数据单元，生成2 个校验单元，共5 个单元，也就是说：这5 个单元中，只要有任意的3个单元存在（不管是数据单元还是校验单元，只要总数=3），就可以得到原始数据。每个单元的大小是1024k=10241024=1048576。
存储的空间冗余率为（3+2)/3 = 1.6
```

- RS-6-3-1024k：
```
使用RS 编码，每6 个数据单元，生成3 个校验单元，共9 个单元，也就是说：这9 个单元中，只要有任意的6 个单元存在（不管是数据单元还是校验单元，只要总数=6），就可以得到原始数据。每个单元的大小是1024k=10241024=1048576。
存储的空间冗余率为（6+3)/6 = 1.5
```

- RS-LEGACY-6-3-1024k：
```
策略和上面的RS-6-3-1024k 一样，只是编码的算法用的是rs-legacy，之前遗留的rs 算法。
```

- XOR-2-1-1024k：
```
使用XOR 编码（速度比RS 编码快），每2个数据单元，生成1 个校验单元，共3 个单元，也就是说：这3个单元中，只要有任意的2个单元存在（不管是数据单元还是校验单元，只要总数=2），就可以得到原始数据。每个单元的大小是1024k=10241024=1048576。
存储的空间冗余率为（2+1)/2 = 1.5
```

-----其他说明-----
```
以RS-6-3-1024k 为例，6 个数据单元+3 个校验单元，可以容忍任意的3 个单元丢失，冗余的数据是50%。而采用副本方式，3 个副本，冗余200%，却还不能容忍任意的3 个单元丢失。（因为有可能副本刚好都在那3个节点上）因此，RS 编码在相同冗余度的情况下，会大大提升数据的可用性，而在相同可用性的情况下，会大大节省冗余空间
```

# 2、纠删码案例实操 

纠删码策略是给具体一个路径设置。所有往此路径下存储的文件，都会执行此策略。

默认只开启对RS-6-3-1024k策略的支持，如要使用别的策略需要提前启用。

1）需求：将/input目录设置为RS-3-2-1024k策略

2）具体步骤

（1）开启对RS-3-2-1024k策略的支持
```
$  hdfs ec -enablePolicy  -policy RS-3-2-1024k
Erasure coding policy RS-3-2-1024k is enabled
```

（2）在HDFS创建目录，并设置RS-3-2-1024k策略
```
$ hdfs dfs -mkdir /input
$ hdfs ec -setPolicy -path /input -policy RS-3-2-1024k
```

（3）上传文件，并查看文件编码后的存储情况
```
$ hdfs dfs -put web.log /input
```
注：你所上传的文件需要大于2M才能看出效果。（低于2M，只有一个数据单元和两个校验单元）

（4）查看存储路径的数据单元和校验单元，并作破坏实验


# 增添自定义纠删码策略示例：

- Hadoop存在一个 `<HDFS客户端安装目录>`/HDFS/hadoop/etc/hadoop/user_ec_policies.xml.template 的EC策略的XML文件示例。

按照模板自定义纠删码策略，示例如下，自定义了两个纠删码策略XORk2m1和RS-legacyk12m4策略：
```
<?xml version="1.0"?> 
 <configuration> 
 <!-- The version of EC policy XML file format, it must be an integer --> 
 <layoutversion>1</layoutversion> 
 <schemas> 
   <!-- schema id is only used to reference internally in this document --> 
   <schema id="XORk2m1"> 
     <!-- The combination of codec, k, m and options as the schema ID, defines 
      a unique schema, for example 'xor-2-1'. schema ID is case insensitive --> 
     <!-- codec with this specific name should exist already in this system --> 
     <codec>xor</codec> 
     <k>2</k> 
     <m>1</m> 
     <options> </options> 
   </schema> 
   <schema id="RS-legacyk12m4"> 
     <codec>rs-legacy</codec> 
     <k>12</k> 
     <m>4</m> 
     <options> </options> 
   </schema> 
 </schemas> 
 <policies> 
   <policy> 
     <!-- the combination of schema ID and cellsize(in unit k) defines a unique 
      policy, for example 'xor-2-1-256k', case insensitive --> 
     <!-- schema is referred by its id --> 
     <schema>XORk2m1</schema> 
     <!-- cellsize must be an positive integer multiple of 1024(1k) --> 
     <!-- maximum cellsize is defined by 'dfs.namenode.ec.policies.max.cellsize' property --> 
     <cellsize>131072</cellsize> 
   </policy> 
   <policy> 
     <schema>RS-legacyk12m4</schema> 
     <cellsize>262144</cellsize> 
   </policy> 
 </policies> 
 </configuration>
```

将上面的纠删码策略加入Hadoop
```
hdfs ec -addPolicies -policyFile <xmlLocation>
```

查看是否加入自定义policy
```
hdfs ec -listPolicies
```

默认加入的策略是disable状态，所以需要进行enable
```
hdfs ec -enablePolicy -policy <policyname>
```
以上便完成了添加自定义纠删码！


# 管理命令

## HDFS提供了ec子命令用于执行纠删码相关的命令
```
# hdfs ec -h
hdfs ec [generic options]
     [-setPolicy -path <path> [-policy <policyName>] [-replicate]]
     [-getPolicy -path <path>]
     [-unsetPolicy -path <path>]
     [-listPolicies]
     [-addPolicies -policyFile <file>]
     [-listCodecs]
     [-enablePolicy -policy <policyName>]
     [-disablePolicy -policy <policyName>]
     [-help [cmd ...]]
```

下面是关于命令的详细说明：

## [-setPolicy -path [-policy ] [-replicate]]  设置纠删码策略到指定路径的目录上
  - **path**： HDFS中的一个目录，这是一个必选参数，设置的策略只会影响到新建的文件，对于已经存在的文件不会有影响。
  - **policyName**： 指定纠删码策略的名称，如果配置项 dfs.namenode.ec.system.default.policy设置了，这个参数可以省略。路径的EC策略就会使用配置项中的默认值
  - **-replicate** 适用于特殊的REPLICATION策略，强制目录采用 3x 复制schema
    - **-replicate** 和 **-policy** 是可选参数，二者不能同时使用
示例：
```
# hdfs ec -setPolicy -path /tmp/ecdata
Set RS-6-3-1024k erasure coding policy on /tmp/ecdata
```

## [-getPolicy -path ]

- 获取指定路径的目录或文件的纠删码的详细信息

示例：
```
# hdfs ec -getPolicy -path /tmp/ecdata
RS-6-3-1024k
```

## [-unsetPolicy -path ]

- 取消指定目录之前设置的纠删码策略，如果目录从祖先目录继承了纠删码策略，则unsetpolicy为no-op，也就是如果我们对一个目录执行了取消策略的操作，如果它的祖先目录设置过了策略，那么取消操作是不会生效的。在没有显式策略集的目录上取消策略不会返回错误。

示例：
```
# 在hdfs文件系统中创建目录
# hadoop fs -mkdir /tmp/ecdata/data1

# 给指定目录设置RS策略
# hdfs ec -setPolicy -path /tmp/ecdata/data1 -policy RS-6-3-1024k
Set RS-6-3-1024k erasure coding policy on /tmp/ecdata/data1

# 获取指定目录的RS策略
# hdfs ec -getPolicy -path /tmp/ecdata/data1
RS-6-3-1024k

# 删除指定目录的策略
# hdfs ec -unsetPolicy -path /tmp/ecdata/data1
Unset erasure coding policy from /tmp/ecdata/data1


# hdfs ec -getPolicy -path /tmp/ecdata/data1
RS-6-3-1024k
# hadoop fs -put test.zip  /tmp/ecdata/data1/123
# hadoop fs -du -s -h /tmp/ecdata/data1
```

## [-listPolicies]

- 列出所有注册到HDFS(enabled, disabled 和 removed)的EC策略，只有状态为enabled的策略才能使用setPolicy命令设置

示例：
```
# hdfs ec -listPolicies
Erasure Coding Policies:
ErasureCodingPolicy=[Name=RS-10-4-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=10, numParityUnits=4]], CellSize=1048576, Id=5], State=DISABLED
ErasureCodingPolicy=[Name=RS-3-2-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=3, numParityUnits=2]], CellSize=1048576, Id=2], State=DISABLED
ErasureCodingPolicy=[Name=RS-6-3-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=1], State=ENABLED
ErasureCodingPolicy=[Name=RS-LEGACY-6-3-1024k, Schema=[ECSchema=[Codec=rs-legacy, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=3], State=DISABLED
ErasureCodingPolicy=[Name=XOR-2-1-1024k, Schema=[ECSchema=[Codec=xor, numDataUnits=2, numParityUnits=1]], CellSize=1048576, Id=4], State=DISABLED
```

## [-addPolicies -policyFile ]

- 添加EC策略，可以参考etc/hadoop/user_ec_policies.xml.template文件查看示例策略文件，最大的cell大小有选项 dfs.namenode.ec.policies.max.cellsize 定义，默认是4MB。当前HDFS支持添加最多64种策略，策略ID的范围是 64-127，如果已经添加了64中策略，那么后面的添加会失败。

## [-listCodecs]

- 获取系统中支持的EC codecs 和coders 的列表。coder是codec的实现。codec可以有不同的实现，也就是不同的coder。一个codec的coder按返回顺序列出。

示例：
```
# hdfs ec -listCodecs
Erasure Coding Codecs: Codec [Coder List]
        RS [RS_NATIVE, RS_JAVA]
        RS-LEGACY [RS-LEGACY_JAVA]
        XOR [XOR_NATIVE, XOR_JAVA]
```

## [-removePolicy -policy ]

- 删除EC策略

## [-enablePolicy -policy ]

- 启用EC策略

示例：
```
# hdfs ec -enablePolicy -policy XOR-2-1-1024k
# hdfs ec -listPolicies
Erasure Coding Policies:
ErasureCodingPolicy=[Name=RS-10-4-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=10, numParityUnits=4]], CellSize=1048576, Id=5], State=DISABLED
ErasureCodingPolicy=[Name=RS-3-2-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=3, numParityUnits=2]], CellSize=1048576, Id=2], State=DISABLED
ErasureCodingPolicy=[Name=RS-6-3-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=1], State=ENABLED
ErasureCodingPolicy=[Name=RS-LEGACY-6-3-1024k, Schema=[ECSchema=[Codec=rs-legacy, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=3], State=DISABLED
ErasureCodingPolicy=[Name=XOR-2-1-1024k, Schema=[ECSchema=[Codec=xor, numDataUnits=2, numParityUnits=1]], CellSize=1048576, Id=4], State=ENABLED
```

## [-disablePolicy -policy ]

- 禁用EC策略

示例：
```
# hdfs ec -disablePolicy -policy XOR-2-1-1024k
Erasure coding policy XOR-2-1-1024k is disabled

# hdfs ec -listPolicies
Erasure Coding Policies:
ErasureCodingPolicy=[Name=RS-10-4-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=10, numParityUnits=4]], CellSize=1048576, Id=5], State=DISABLED
ErasureCodingPolicy=[Name=RS-3-2-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=3, numParityUnits=2]], CellSize=1048576, Id=2], State=DISABLED
ErasureCodingPolicy=[Name=RS-6-3-1024k, Schema=[ECSchema=[Codec=rs, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=1], State=ENABLED
ErasureCodingPolicy=[Name=RS-LEGACY-6-3-1024k, Schema=[ECSchema=[Codec=rs-legacy, numDataUnits=6, numParityUnits=3]], CellSize=1048576, Id=3], State=DISABLED
ErasureCodingPolicy=[Name=XOR-2-1-1024k, Schema=[ECSchema=[Codec=xor, numDataUnits=2, numParityUnits=1]], CellSize=1048576, Id=4], State=DISABLED
```





