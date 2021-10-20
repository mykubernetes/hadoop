# 一、hbase web操作

访问地址 http://h71:60010

注：h71的ip配置在$HBASE_HOME/conf/hbase-site.xml中
```
hbase.master.info.port
HBase Master web 界面端口. 设置为 -1 意味着你不想让它运行
默认: 60010
注：新版本改为16010了，所以得访问http://h71:16010了

hbase.master.info.bindAddress
HBase Master web 界面绑定的IP地址
默认: 0.0.0.0
```

ip映射成主机名：
- linux：在/etc/hosts中配置
- windows：在windows系统中的C:\Windows\System32\drivers\etc目录下的hosts文件中配置
```
192.168.8.71    h71
192.168.8.72    h72
192.168.8.73    h73
```

# 二、hbase shell 基本操作

## 1.进入hbase shell console：

注：如果有kerberos认证，需要事先使用相应的keytab进行一下认证（使用kinit命令），认证成功之后再使用hbase shell进入可以使用whoami命令可查看当前用户。
```
$HBASE_HOME/bin/hbase shell
hbase(main):029:0> whoami
hadoop (auth:SIMPLE)
    groups: hadoop
    
hbase(main):008:0> version
1.0.0-cdh5.5.2, rUnknown, Mon Jan 25 16:33:02 PST 2016

list                 # 看库中所有表
status               # 查看当前运行服务器状态
exits '表名字'        # 判断表存在
```

## 2.命名空间Namespace：

在关系数据库系统中，命名空间namespace指的是一个表的逻辑分组，同一组中的表有类似的用途。命名空间的概念为即将到来的多租户特性打下基础：
- 配额管理（Quota Management (HBASE-8410)）：限制一个namespace可以使用的资源，资源包括region和table等；
- 命名空间安全管理（Namespace Security Administration (HBASE-9206)）：提供了另一个层面的多租户安全管理；
- Region服务器组（Region server groups (HBASE-6721)）：一个命名空间或一张表，可以被固定到一组regionservers上，从而保证了数据隔离性。

### （1）命名空间管理：

命名空间可以被创建、移除、修改。表和命名空间的隶属关系在在创建表时决定，通过以下格式指定：`<namespace>:<table>`

Example：hbase shell中创建命名空间、创建命名空间中的表、移除命名空间、修改命名空间：
```
#Create a namespace
create_namespace 'my_ns'

#create my_table in my_ns namespace
create 'my_ns:my_table', 'fam'

#drop namespace
drop_namespace 'my_ns'
注意：只有当该空间不存在任何表为空的时候才可以删除，如果存在表的话应该将表删除后再删除该空间，删除表的操作：
hbase(main):005:0> disable 'my_ns:my_table'
hbase(main):006:0> drop 'my_ns:my_table'

#alter namespace
alter_namespace 'my_ns', {METHOD => 'set', 'PROPERTY_NAME' => 'PROPERTY_VALUE'}

# 列出所有namespace
list_namespace

# 查看namespace
hbase(main):005:0> describe_namespace 'hbase'
DESCRIPTION                                                                                                                                                                                    
{NAME => 'hbase'}                                                                                                                                                                              
Took 0.0206 seconds                                                                                                                                                                            
=> 1
```

### （2）预定义的命名空间：

有两个系统内置的预定义命名空间：
- hbase：系统命名空间，用于包含hbase的内部表
- default：所有未指定命名空间的表都自动进入该命名空间

```
#使用默认的命名空间：namespace=my_ns and table qualifier=bar
create 'my_ns:bar', 'fam'

#指定命名空间：namespace=default and table qualifier=bar
create 'bar', 'fam'
```

## 3.创建表：

语法：`create <table>, {NAME => <family>, VERSIONS => <VERSIONS>}`

具体命令：
```
create 't1', {NAME => 'f1', VERSIONS => 5}
create 't1', {NAME => 'f1'}, {NAME => 'f2'}, {NAME => 'f3'}
```

省略模式建立列族：`create 't1', 'f1', 'f2', 'f3'`

指定每个列族参数：
```
create 't1', {NAME => 'f1', VERSIONS => 1, TTL => 2592000, BLOCKCACHE => true}
create 't1', 'f1', {SPLITS => ['10', '20', '30', '40']}
```

设置不同参数，提升表的读取性能：
```
create 'lmj_test',
        {NAME => 'adn', DATA_BLOCK_ENCODING => 'NONE', BLOOMFILTER => 'ROWCOL', REPLICATION_SCOPE => '0', COMPRESSION => 'SNAPPY', VERSIONS => '1', TTL => '15768000', MIN_VERSIONS => '0', KEEP_DELETED_CELLS => 'false', BLOCKSIZE => '65536', ENCODE_ON_DISK => 'true', IN_MEMORY => 'false', BLOCKCACHE => 'false'}, 
        {NAME => 'fixeddim', DATA_BLOCK_ENCODING => 'NONE', BLOOMFILTER => 'ROWCOL', REPLICATION_SCOPE => '0', COMPRESSION => 'SNAPPY', VERSIONS => '1', TTL => '15768000', MIN_VERSIONS => '0', KEEP_DELETED_CELLS => 'false', BLOCKSIZE => '65536', ENCODE_ON_DISK => 'true', IN_MEMORY => 'false', BLOCKCACHE => 'false'}, 
        {NAME => 'social', DATA_BLOCK_ENCODING => 'NONE', BLOOMFILTER => 'ROWCOL', REPLICATION_SCOPE => '0', COMPRESSION => 'SNAPPY', VERSIONS => '1', TTL => '15768000', MIN_VERSIONS => '0', KEEP_DELETED_CELLS => 'false', BLOCKSIZE => '65536', ENCODE_ON_DISK => 'true', IN_MEMORY => 'false', BLOCKCACHE => 'false'}
```

每个参数属性都有性能意义，通过合理化的设置可以提升表的性能：
```
create 'lmj_test',
        {NAME => 'adn', BLOOMFILTER => 'ROWCOL', VERSIONS => '1', TTL => '15768000', MIN_VERSIONS => '0', COMPRESSION => 'SNAPPY', BLOCKCACHE => 'false'},
        {NAME => 'fixeddim',BLOOMFILTER => 'ROWCOL', VERSIONS => '1', TTL => '15768000', MIN_VERSIONS => '0', COMPRESSION => 'SNAPPY', BLOCKCACHE => 'false'},
        {NAME => 'social',BLOOMFILTER => 'ROWCOL', VERSIONS => '1', TTL => '15768000', MIN_VERSIONS => '0',COMPRESSION => 'SNAPPY', BLOCKCACHE => 'false'}
```


## 4.修改存储版本数及版本号查询：

Hbase中通过row和columns确定的为一个存贮单元称为cell，每个 cell都保存着同一份数据的多个版本。在默认的情况下，HBase会存储三个版本的历史数据。但是在实际应用中，出于性能或业务需要，我们可能只有一个或其他数量的版本需要存储。那么如何修改这一默认配置呢？

### （1）建表时配置：

如果你还没有建表，那你可以在建表时指定VERSIONS来设定版本号，就是存储几个版本的数据。
```
create '表名',{NAME='列族名1',VERSIONS=给定一个版本号},{NAME='列族名2',VERSIONS=给定的版本号}
```


### （2）修改表配置：

如果在建表时没有指定版本号，那么就需要按照以下步骤修改表配置。

在表已经建好的情况下，需要首先将表下线：
```
disable 'table'
```

修改表属性(可指定对某个列族修改)：
```
alter 'table' , NAME => 'f', VERSIONS => 1
```

重新上线（enable）：
```
enable 'table'
```

### （3）版本号查询：

  根据版本号我们可以指定查询几个版本的数据，目前该表的VERSIONS为10：
```
hbase(main):060:0> scan 'test_schema1:t2'
ROW                                               COLUMN+CELL                                                                                                                                      
0 row(s)
Took 0.1183 seconds                                                                                                                                                                                
hbase(main):061:0> put 'test_schema1:t2','101','F:b','huiqtest1'
Took 0.0050 seconds                                                                                                                                                                                
hbase(main):062:0> put 'test_schema1:t2','101','F:b','huiqtest2'
Took 0.0046 seconds                                                                                                                                                                                
hbase(main):063:0> put 'test_schema1:t2','101','F:b','huiqtest3'
Took 0.0157 seconds                                                                                                                                                                                
hbase(main):064:0> scan 'test_schema1:t2'
ROW                                               COLUMN+CELL                                                                                                                                      
 101                                              column=F:b, timestamp=1627353050875, value=huiqtest3                                                                                             
1 row(s)
Took 0.0048 seconds                                                                                                                                                                                
hbase(main):065:0> scan 'test_schema1:t2', {VERSIONS=>3}
ROW                                               COLUMN+CELL                                                                                                                                      
 101                                              column=F:b, timestamp=1627353050875, value=huiqtest3                                                                                             
 101                                              column=F:b, timestamp=1627353048782, value=huiqtest2                                                                                             
 101                                              column=F:b, timestamp=1627353045389, value=huiqtest1                                                                                             
1 row(s)
Took 0.0097 seconds                                                                                                                                                                                
hbase(main):066:0> scan 'test_schema1:t2', {COLUMNS => ['F:a', 'F:b'], VERSIONS=>3}
ROW                                               COLUMN+CELL                                                                                                                                      
 101                                              column=F:b, timestamp=1627353050875, value=huiqtest3                                                                                             
 101                                              column=F:b, timestamp=1627353048782, value=huiqtest2                                                                                             
 101                                              column=F:b, timestamp=1627353045389, value=huiqtest1                                                                                             
1 row(s)
Took 0.0088 seconds                                                                                                                                                                                                                       
hbase(main):068:0> get 'test_schema1:t2','101','F:b'
COLUMN                                            CELL                                                                                                                                             
 F:b                                              timestamp=1627353050875, value=huiqtest3                                                                                                         
1 row(s)
Took 0.0154 seconds                                                                                                                                                                                
hbase(main):069:0> get 'test_schema1:t2','101', {COLUMNS => ['F:b'], VERSIONS=>3}
COLUMN                                            CELL                                                                                                                                             
 F:b                                              timestamp=1627353050875, value=huiqtest3                                                                                                         
 F:b                                              timestamp=1627353048782, value=huiqtest2                                                                                                         
 F:b                                              timestamp=1627353045389, value=huiqtest1                                                                                                         
1 row(s)
Took 0.0163 seconds                                                                                                                                                                                
hbase(main):070:0> get 'test_schema1:t2','101', {COLUMNS => 'F:b', VERSIONS=>3}
COLUMN                                            CELL                                                                                                                                             
 F:b                                              timestamp=1627353050875, value=huiqtest3                                                                                                         
 F:b                                              timestamp=1627353048782, value=huiqtest2                                                                                                         
 F:b                                              timestamp=1627353045389, value=huiqtest1                                                                                                         
1 row(s)
Took 0.0044 seconds             
hbase(main):073:0> put 'test_schema1:t2','101','F:a','101'
Took 0.0660 seconds            
hbase(main):077:0> get 'test_schema1:t2','101', {COLUMNS => ['F:a', 'F:b'], VERSIONS=>2}
COLUMN                                            CELL                                                                                                                                             
 F:a                                              timestamp=1627353603902, value=101                                                                                                               
 F:b                                              timestamp=1627353050875, value=huiqtest3                                                                                                         
 F:b                                              timestamp=1627353048782, value=huiqtest2                                                                                                         
1 row(s)
Took 0.0053 seconds       

# 删除指定版本的数据
hbase(main):078:0> delete 'test_schema1:t2','101','F:b',1627353048782
Took 0.0136 seconds                                                                                                                                                                                
hbase(main):079:0> get 'test_schema1:t2','101', {COLUMNS => ['F:a', 'F:b'], VERSIONS=>2}
COLUMN                                            CELL                                                                                                                                             
 F:a                                              timestamp=1627353603902, value=101                                                                                                               
 F:b                                              timestamp=1627353050875, value=huiqtest3                                                                                                         
 F:b                                              timestamp=1627353045389, value=huiqtest1                                                                                                         
1 row(s)
Took 0.0115 seconds                                                          
```

## 5.在创建的表中插入数据：
```
hbase(main):180:0> put 'scores','zhangsan01','course:math','99'
hbase(main):181:0> put 'scores','zhangsan01','course:art','90'
hbase(main):182:0> put 'scores','zhangsan01','grade:','101'
hbase(main):184:0> put 'scores','zhangsan02','course:math','66'
hbase(main):185:0> put 'scores','zhangsan02','course:art','60'
hbase(main):186:0> put 'scores','zhangsan02','grade:','102'
hbase(main):201:0> put 'scores','lisi01','course:math','89'
hbase(main):202:0> put 'scores','lisi01','course:art','89'
hbase(main):203:0> put 'scores','lisi01','grade:','201'
```

## 6.更新数据：

更新表数据与插入表数据一样，都使用put命令，如下：

  ```
# 语法：
put ‘tablename’,’row’,’colfamily:colname’,’newvalue’

# 更新emp表中row为1，将列为personal data:city的值更改为bj
put ‘emp’,’1’,’personal data:city’,’bj’
```

## 7.复制表：

如何在hbase里面复制出一张表呢？用快照复制：

步骤1：创建表的快照
```
hbase(main):204:0> snapshot 'scores' , 'snapshot_scores'
```

步骤2：从快照克隆出一张新的表
```
hbase(main):205:0> clone_snapshot 'snapshot_scores','scores_2'
```

如果加表空间的话：
```
hbase(main):206:0> snapshot 'test_schema1:t1', 'snapshot_t1'
hbase(main):207:0> clone_snapshot 'snapshot_t1','test_schema1:t2'
```

## 8.查看删除快照：
```
# 查看快照
hbase(main):208:0> list_snapshots
SNAPSHOT                                         TABLE + CREATION TIME                                                                                                                         
 snapshot_t1                                     test_schema1:t1 (2021-07-09 16:28:03 +0800)                                                                                                   
1 row(s)
Took 0.5443 seconds                                                                                                                                                                            
=> ["snapshot_t1"]

# 删除快照
hbase(main):209:0> delete_snapshot 'snapshot_t1'
```
注意：0.94.x版本之前是不支持snapshot快照命令的。

## 9.数据查询：

### 1)创建并插入数据：
```
hbase(main):179:0> create 'scores','grade','course'
hbase(main):180:0> put 'scores','zhangsan01','course:art','90'
hbase(main):181:0> scan 'scores'
ROW                                                          COLUMN+CELL                                                                                               
 zhangsan01                                                  column=course:art, timestamp=1498003561726, value=90                                                     
1 row(s) in 0.0150 seconds

hbase(main):182:0> put 'scores','zhangsan01','course:math','99',1498003561726
# 这里手动设置时间戳的时候一定不能大于你当前的系统时间，否则的话无法删除该数据，我这里手动设置数据是为了下面的DependentColumnFilter过滤器试验。你可以查看一下插入第一条数据的时间戳，再插入第二条数据的时间戳为第一条数据的时间戳

hbase(main):183:0> put 'scores','zhangsan01','grade:','101'
# 问题：当我将这条插入的数据删除之后再执行put 'scores','zhangsan01','grade:','101',1498003561726后能成功却scan 'scores'后没有该条数据，而再执行put 'scores','zhangsan01','grade:','101'后scan 'scores'却能查到该条数据。如果想插入该条数据的时候手动设置时间戳的话，必须在第一次插入该条数据或者truncate后再插入。

hbase(main):184:0> put 'scores','zhangsan02','course:art','90'

hbase(main):185:0> get 'scores','zhangsan02','course:art'
COLUMN                                                       CELL
 course:art                                                  timestamp=1498003601365, value=90     
1 row(s) in 0.0080 seconds

hbase(main):186:0> put 'scores','zhangsan02','grade:','102',1498003601365
hbase(main):187:0> put 'scores','zhangsan02','course:math','66',1498003561726
hbase(main):188:0> put 'scores','lisi01','course:math','89',1498003561726
hbase(main):189:0> put 'scores','lisi01','course:art','89'
hbase(main):190:0> put 'scores','lisi01','grade:','201',1498003561726
```

### 2)根据rowkey查询：
```
hbase(main):187:0> get 'scores','zhangsan01'
COLUMN                                                      CELL
course:art                                                  timestamp=1498003561726, value=90
course:math                                                 timestamp=1498003561726, value=99
grade:                                                      timestamp=1498003593575, value=101
3 row(s) in 0.0160 seconds
```

### 3)根据列名查询：
```
hbase(main):188:0> scan 'scores',{COLUMNS=>'course:art'}
ROW                                                         COLUMN+CELL
lisi01                                                      column=course:art, timestamp=1498003655021, value=89
zhangsan01                                                  column=course:art, timestamp=1498003561726, value=90
zhangsan02                                                  column=course:art, timestamp=1498003601365, value=90
3 row(s) in 0.0120 seconds
```

### 4)查询两个rowkey之间的数据：
```
hbase(main):205:0> scan 'scores',{STARTROW=>'zhangsan01',STOPROW=>'zhangsan02'}
ROW                                                         COLUMN+CELL
zhangsan01                                                  column=course:art, timestamp=1498003561726, value=90
zhangsan01                                                  column=course:math, timestamp=1498003561726, value=99
zhangsan01                                                  column=grade:, timestamp=1498003593575, value=101
1 row(s) in 0.0140 seconds
```

### 5)查询两个rowkey且根据列名来查询：
```
hbase(main):206:0> scan 'scores',{COLUMNS=>'course:art',STARTROW=>'zhangsan01',STOPROW=>'zhangsan02'}
ROW                                                         COLUMN+CELL
zhangsan01                                                  column=course:art, timestamp=1498003561726, value=90
1 row(s) in 0.0110 seconds
```

### 6)查询指定rowkey到末尾根据列名的查询：
```
hbase(main):207:0> scan 'scores',{COLUMNS=>'course:art',STARTROW=>'zhangsan01',STOPROW=>'zhangsan09'}
ROW                                                         COLUMN+CELL
zhangsan01                                                  column=course:art, timestamp=1498003561726, value=90
zhangsan02                                                  column=course:art, timestamp=1498003601365, value=90
2 row(s) in 0.0310 seconds
```

### 7)限制查找条数：
```
hbase(main):208:0> scan 'scores',{LIMIT=>1}
ROW                                                         COLUMN+CELL
zhangsan01                                                  column=course:art, timestamp=1498003561726, value=90
zhangsan01                                                  column=course:math, timestamp=1498003561726, value=99
zhangsan01                                                  column=grade:, timestamp=1498003593575, value=101
1 row(s) in 0.0140 seconds
```

### 8)限制时间范围：
```
hbase(main):209:0> scan 'scores',{TIMERANGE=>[1498003561720,1498003594575]}
ROW                                                         COLUMN+CELL
zhangsan01                                                  column=course:art, timestamp=1498003561726, value=90
zhangsan01                                                  column=course:math, timestamp=1498003561726, value=99
zhangsan01                                                  column=grade:, timestamp=1498003593575, value=101
1 row(s) in 0.0140 seconds
```

### 9)利用scan查看同一个cell之前已经put的数据：

scan时可以设置是否开启RAW模式，开启RAW模式会返回已添加删除标记但是未实际进行删除的数据：

说明：虽然已经put覆盖了之前同一个cell的数据，但是实际上数据并没有进行删除，只是标记删除了，利用RAW模式可以看到：
```
hbase(main):044:0> scan 'test_schema1:t2'
ROW                                              COLUMN+CELL
101                                              column=F:a, timestamp=1627351985825, value=101
101                                              column=F:b, timestamp=1627352011077, value=huiqtest2
102                                              column=F:a, timestamp=1627351998674, value=102
102                                              column=F:b, timestamp=1627352044369, value=huiqtest22
2 row(s)
Took 0.0059 seconds                                                                                                                                                                                
hbase(main):045:0> deleteall 'test_schema1:t2','102'
Took 0.0601 seconds                                                                                                                                                                                
hbase(main):046:0> delete 'test_schema1:t2','101','F:b'
Took 0.0079 seconds                                                                                                                                                                                
hbase(main):047:0> scan 'test_schema1:t2'
ROW                                              COLUMN+CELL
101                                              column=F:a, timestamp=1627351985825, value=101
101                                              column=F:b, timestamp=1627351960913, value=huiqtest
1 row(s)
Took 0.0083 seconds                                                                                                                                                                                
hbase(main):048:0> scan 'test_schema1:t2', {RAW=>true, VERSIONS=>1}                #RAW=true
ROW                                              COLUMN+CELL
101                                              column=F:a, timestamp=1627351985825, value=101
101                                              column=F:b, timestamp=1627352011077, type=Delete
101                                              column=F:b, timestamp=1627352011077, value=huiqtest2
102                                              column=F:, timestamp=1627352086801, type=DeleteFamily
102                                              column=F:a, timestamp=1627351998674, value=102
102                                              column=F:b, timestamp=1627352044369, value=huiqtest22
2 row(s)
Took 0.0061 seconds    
```
get获取某个cell保留的（未添加删除标记）的所有version数据（在describe 表名，查看列族VERSIONS是多少，get就会多少数据(cell的数据大于等于VERSIONS的数量)）


## 10.delete 删除数据：

删除指定行中指定列：

语法：`delete <table>, <rowkey>, <family:column> , <timestamp>`(必须指定列名，删除其所有版本数据)
```
delete 'scores','zhangsan01','course:math'
```

删除整行数据（可不指定列名）：

语法：`deleteall <table>, <rowkey>, <family:column> , <timestamp>`
```
deleteall 'scores','zhangsan02'
```

注：Put，Delete，Get，Scan这四个类都是org.apache.hadoop.hbase.client的子类，可以到官网API去查看详细信息。
 
## 11.count统计表中记录数：
```
# 每100条显示一次，缓存区为500
count 'scores', {INTERVAL => 100, CACHE => 500}
```

## 12.清空表：
```
truncate 'scores'
```

## 13.修改表结构：

- 先disable后enable
```
# 例如：修改表scores的cf的TTL为180天
hbase(main):017:0> disable 'scores'
hbase(main):018:0> alter 'scores',{NAME=>'grade',TTL=>'15552000'},{NAME=>'course', TTL=>'15552000'}
Updating all regions with the new schema...
1/1 regions updated.
Done.
Updating all regions with the new schema...
1/1 regions updated.
Done.
0 row(s) in 2.2200 seconds

#改变多版本号：
hbase(main):019:0> alter 'scores',{NAME=>'grade',VERSIONS=>3}
Updating all regions with the new schema...
0/1 regions updated.
1/1 regions updated.
Done.
0 row(s) in 2.4020 seconds
注：网上都说修改表结构必须先先disable后enable，但是我没有做这个操作，直接alter也成功了啊，不知道这样做有没有什么影响，目前还不太了解。

# 增加列族：
hbase(main):020:0> alter 'scores',NAME=>'info'
# 删除列族：
alter 'scores′， NAME=> 'info′，METHOD => 'delete'
# 或者
alter 'scores′，'delete' => 'info′

hbase(main):020:0> enable 'scores'
```

## 14.查看HBase表的创建时间：

hbase:meta表会记录元数据信息，而这些数据在创建时也会有timestamp属性。rowkey就是表名（格式是namespace:table）看一下查到的数据的时间戳，然后把时间戳转为时间串。
```
hbase(main):146:0> get 'hbase:meta','datawarehouse_ods:osd_dw_4027_apply'
COLUMN                                        CELL
 table:state                                  timestamp=1630487793994, value=\x08\x00
1 row(s)
Took 0.0049 seconds
```

此外，也可以到zookeeper中查看相关信息，使用get /hbase/table/表名（格式是namespace:table）查询到的ctime属性就是创建时间了。
```
[zk: localhost:2181(CONNECTED) 7] get /hbase-unsecure/table/datawarehouse_ods:ods_dw_4027_apply
?master:16000U?oA?
cZxid = 0x2100058ba0
cTime = Web Sep 01 17:14:22 CST 2021         # 节点创建时间
mZxid = 0x2100058dce
mtime = Wed Sep 01 17:16:34 CST 2021
pZxid = 0x2100058ba0
cversion = 0
dataVersion = 6
ephemeral0wner = 0x0
aclVersion = 0
dataLength = 31
numChildren = 0
```

## 15.删除表：
```
hbase(main):044:0> disable 't2'                                                                                                                                                              
hbase(main):045:0> drop 't2'
```

## 16.表操作权限：

### （1）分配权限：
```
grant 'hadoop','RW','scores'    #分配给用户hadoop表scores的读写权限
```

注意：一开始我分配权限的时候总是报错：
```
hbase(main):038:0> grant 'hadoop','RW','scores'

ERROR: DISABLED: Security features are not available
```

解决：
```
[hadoop@h71 ~]$ vi hbase-1.0.0-cdh5.5.2/conf/hbase-site.xml
添加：
<property>
  <name>hbase.superuser</name>
  <value>root,hadoop</value>
</property>
<property>
  <name>hbase.coprocessor.region.classes</name>
  <value>org.apache.hadoop.hbase.security.access.AccessController</value>
</property>
<property>
  <name>hbase.coprocessor.master.classes</name>
  <value>org.apache.hadoop.hbase.security.access.AccessController</value>
</property>
<property>
  <name>hbase.rpc.engine</name>
  <value>org.apache.hadoop.hbase.ipc.SecureRpcEngine</value>
</property>
<property>
  <name>hbase.security.authorization</name>
  <value>true</value>
</property>
```

同步hbase配置（我的hbase集群为h71（主），h72（从），h73（从））：
```
[hadoop@h71 ~]$ cat /home/hadoop/hbase-1.0.0-cdh5.5.2/conf/regionservers|xargs -i -t scp /home/hadoop/hbase-1.0.0-cdh5.5.2/conf/hbase-site.xml hadoop@{}:/home/hadoop/hbase-1.0.0-cdh5.5.2/conf/hbase-site.xml
scp /home/hadoop/hbase-1.0.0-cdh5.5.2/conf/hbase-site.xml hadoop@h72:/home/hadoop/hbase-1.0.0-cdh5.5.2/conf/hbase-site.xml 
hbase-site.xml                                                                                                                                                                                             100% 2038     2.0KB/s   00:00    
scp /home/hadoop/hbase-1.0.0-cdh5.5.2/conf/hbase-site.xml hadoop@h73:/home/hadoop/hbase-1.0.0-cdh5.5.2/conf/hbase-site.xml 
hbase-site.xml                                                                                                                                                                                             100% 2038     2.0KB/s   00:00
```
重启hbase集群。

注：

HBase提供的五个权限标识符：RWXCA，分别对应着READ(‘R’)、WRITE(‘W’)、EXEC(‘X’)、CREATE(‘C’)、ADMIN(‘A’)

HBase提供的安全管控级别包括：

- Superuser：拥有所有权限的超级管理员用户。通过hbase.superuser参数配置
- Global：全局权限可以作用在集群所有的表上。
- Namespace ：命名空间级。
- Table：表级。
- ColumnFamily：列簇级权限。
- Cell：单元级。

和关系数据库一样，权限的授予和回收都使用grant和revoke，但格式有所不同。grant语法格式：`grant user permissions table column_family column_qualifier`

### （2）查看权限：
```
hbase(main):010:0> user_permission 'scores'
User                                                         Namespace,Table,Family,Qualifier:Permission                                                                                                                                     
 hadoop                                                      default,scores,,: [Permission: actions=READ,WRITE]                                                                                                                              
1 row(s) in 0.2530 seconds
```

（3）收回权限：
```
hbase(main):006:0> revoke 'hadoop','scores'
```


## 17.hbase shell脚本：

既然是shell命令，当然也可以把所有的hbase shell命令写入到一个文件内，想Linux shell脚本程序那样去顺序的执行所有命令。如同写linux shell，把所有hbase shell命令书写在一个文件内，然后执行如下命令即可：

```
[hadoop@h71 hbase-1.0.0-cdh5.5.2]$ vi hehe.txt（这个文件名随便起，正规点的话可以起test.hbaseshell）
create 'hui','cf'
list
disable 'hui'
drop 'hui'
list
[hadoop@h71 hbase-1.0.0-cdh5.5.2]$ bin/hbase shell hehe.txt
```

## 18.跨集群数据迁移

###（1）Export/Import方式：

迁移原集群的表：
```
hbase(main):012:0> count 'test_schemal:t2'
38 row(s)
Took 0.0210 seconds
=> 38
```

步骤一：在目标集群创建对应表
```
hbase(main):015:0> create 'test_schemal:t2', {NAME => 'F', VERSIONS => 99999}
Created table test_schemal:t2
Took 4.3567 seconds
=> Hbase::Table - test_schemal:t2
```

步骤二：Export阶段：将原集群表数据Scan并转换成Sequence File到Hdfs上，因Export也是依赖于MR的，如果用到独立的MR集群的话，只要保证在MR集群上关于HBase的配置和原集群一样且能和原集群策略打通，就可直接用Export命令。若需要同步多个版本数据，可以指定versions参数，否则默认同步最新版本的数据，还可以指定数据起始结束时间，使用如下：
```
# output_hdfs_path可以直接是目标集群的hdfs路径，也可以是原集群的HDFS路径，如果需要指定版本号，起始结束时间
hbase org.apache.hadoop.hbase.mapreduce.Export <tableName> <ouput_hdfs_path> <versions> <starttime> <endtime> 

# 实操：
[root@node01 ~]# hbase org.apache.hadoop.hbase.mapreduce.Export test_schema1:t2 /huiq 99999
# 注意：执行该命令前/huiq目录不能存在
```

步骤三：Import阶段：将原集群Export出的SequenceFile导到目标集群对应表，使用如下：
```
# 如果原数据是存在原集群HDFS，此处input_hdfs_path可以是原集群的HDFS路径，如果原数据存在目标集群HDFS，则为目标集群的HDFS路径
hbase org.apache.hadoop.hbase.mapreduce.Import <tableName> <input_hdfs_path>

# 实操：
[hdfs@bigdatanode01 ~]$ hbase org.apache.hadoop.hbase.mapreduce.Import test_schema1:t2 hdfs://192.110.110.110:8020/huiq
```
注意：在执行步骤三的时候可能报错

解决：切换到hdfs用户（su - hdfs）再执行Import命令即可

## 19.hbase hbck：

hbase hbck是hbase自带的一项非常实用的工具，很多hbase中出现的问题都可以尝试用hbase hbck修复。
  
hbck 是一个检查和修复表，region一致性和完整性的工具。新版本的hbck从 hdfs目录、META、RegionServer 这三处获得region的Table和Region的相关信息，根据这些信息判断并尝试进行repair。

新版本的 hbck 可以修复各种错误，修复选项是：（请注意选项后面是否需要加具体表名）
```
（1）-fix
    向下兼容用，被-fixAssignments替代   
（2）-fixAssignments
    用于修复region assignments错误   
（3）-fixMeta
    用于修复meta表的问题，前提是HDFS上面的region info信息有并且正确。   
（4）-fixHdfsHoles
    修复region holes（空洞，某个区间没有region）问题   
（5）-fixHdfsOrphans
    修复Orphan region（hdfs上面没有.regioninfo的region）   
（6）-fixHdfsOverlaps
    修复region overlaps（区间重叠）问题   
（7）-fixVersionFile
    修复缺失hbase.version文件的问题   
（8）-maxMerge <n> （n默认是5）
    当region有重叠是，需要合并region，一次合并的region数最大不超过这个值。   
（9）-sidelineBigOverlaps 
    当修复region overlaps问题时，允许跟其他region重叠次数最多的一些region不参与（修复后，可以把没有参与的数据通过bulk load加载到相应的region）   
（10）-maxOverlapsToSideline <n> （n默认是2）
    当修复region overlaps问题时，一组里最多允许多少个region不参与。由于选项较多，所以有两个简写的选项   
（11）-repair
    相当于-fixAssignments -fixMeta -fixHdfsHoles -fixHdfsOrphans -fixHdfsOverlaps -fixVersionFile -sidelineBigOverlaps。如前所述，-repair 打开所有的修复选项，相当于-fixAssignments -fixMeta -fixHdfsHoles -fixHdfsOrphans -fixHdfsOverlaps -fixVersionFile -sidelineBigOverlaps   
（12）-repairHoles
    相当于-fixAssignments -fixMeta -fixHdfsHoles -fixHdfsOrphans  
 ```
示例情景：  
```
Q：缺失hbase.version文件   
A：加上选项 -fixVersionFile 解决 
  
Q：如果一个region即不在META表中，又不在hdfs上面，但是在regionserver的online region集合中   
A：加上选项 -fixAssignments 解决  
 
Q：如果一个region在META表中，并且在regionserver的online region集合中，但是在hdfs上面没有   
A：加上选项 -fixAssignments -fixMeta 解决，（ -fixAssignments告诉regionserver close region），（ -fixMeta删除META表中region的记录） 
 
Q：如果一个region在META表中没有记录，没有被regionserver服务，但是在hdfs上面有   
A：加上选项 -fixMeta -fixAssignments 解决，（ -fixAssignments 用于assign region），（ -fixMeta用于在META表中添加region的记录）   
 
Q：如果一个region在META表中没有记录，在hdfs上面有，被regionserver服务了   
A：加上选项 -fixMeta 解决，在META表中添加这个region的记录，先undeploy region，后assign。-fixMeta，如果hdfs上面没有，那么从META表中删除相应的记录，如果hdfs上面有，在META表中添加上相应的记录信息 
   
Q：如果一个region在META表中有记录，但是在hdfs上面没有，并且没有被regionserver服务   
A：加上选项 -fixMeta 解决，删除META表中的记录   
 
Q：如果一个region在META表中有记录，在hdfs上面也有，table不是disabled的，但是这个region没有被服务   
A：加上选项 -fixAssignments 解决，assign这个region。-fixAssignments，用于修复region没有assign、不应该assign、assign了多次的问题   
 
Q：如果一个region在META表中有记录，在hdfs上面也有，table是disabled的，但是这个region被某个regionserver服务了   
A：加上选项 -fixAssignments 解决，undeploy这个region  
 
Q：如果一个region在META表中有记录，在hdfs上面也有，table不是disabled的，但是这个region被多个regionserver服务了   
A：加上选项 -fixAssignments 解决，通知所有regionserver close region，然后assign region 
  
Q：如果一个region在META表中，在hdfs上面也有，也应该被服务，但是META表中记录的regionserver和实际所在的regionserver不相符   
A：加上选项 -fixAssignments 解决   
   
Q：region holes   
A：加上 -fixHdfsHoles ，创建一个新的空region，填补空洞，但是不assign 这个 region，也不在META表中添加这个region的相关信息。修复region holes时，-fixHdfsHoles 选项只是创建了一个新的空region，填补上了这个区间，还需要加上-fixAssignments -fixMeta 来解决问题，（ -fixAssignments 用于assign region），（ -fixMeta用于在META表中添加region的记录），所以有了组合拳 -repairHoles 修复region holes，相当于-fixAssignments -fixMeta -fixHdfsHoles -fixHdfsOrphans 
 
Q：region在hdfs上面没有.regioninfo文件   
A：加上选项 -fixHdfsOrphans 解决   
 
Q：region overlaps   
A：需要加上 -fixHdfsOverlaps
```

该命令输出如下：
```
[root@node01 spark2]# hbase hbck
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/hdp/3.1.4.0-315/phoenix/phoenix-5.0.0.3.1.4.0-315-server.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/hdp/3.1.4.0-315/hadoop/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
2021-07-23 09:25:41,838 INFO  [main] zookeeper.RecoverableZooKeeper: Process identifier=hbase Fsck connecting to ZooKeeper ensemble=node01:2181,node02:2181,node03:2181
2021-07-23 09:25:41,850 INFO  [main] zookeeper.ZooKeeper: Client environment:zookeeper.version=3.4.6-315--1, built on 08/23/2019 05:02 GMT
2021-07-23 09:25:41,850 INFO  [main] zookeeper.ZooKeeper: Client environment:host.name=node01
2021-07-23 09:25:41,850 INFO  [main] zookeeper.ZooKeeper: Client environment:java.version=1.8.0_231
2021-07-23 09:25:41,850 INFO  [main] zookeeper.ZooKeeper: Client environment:java.vendor=Oracle Corporation
2021-07-23 09:25:41,850 INFO  [main] zookeeper.ZooKeeper: Client environment:java.home=/opt/tools/jdk1.8.0_231/jre
2021-07-23 09:25:41,851 INFO  [main] zookeeper.ZooKeeper: Client environment:java.class.path=/etc/hbase/conf:/opt/tools/jdk1.8.0_231/lib/tools.jar:/usr/hdp/3.1.4.0-315/hbase:/usr/hdp/3.1.4.0-315/hbase/lib/animal-sniffer-annotations-1.17.jar:/usr/hdp/3.1.4.0-315/hbase/lib/aopalliance-1.0.jar:/usr/hdp/3.1.4.0-315/hbase/lib/aopalliance-repackaged-2.5.0-b32.jar:/usr/hdp/3.1.4.0-315/hbase/lib/atlas-plugin-classloader-1.1.0.3.1.4.0-315.jar:/usr/hdp/3.1.4.0-315/hbase/lib/audience-annotations-0.5.0.jar:/usr/hdp/3.1.4.0-315/hbase/lib/avro-1.7.7.jar:/usr/hdp/3.1.4.0-315/hbase/lib/aws-java-sdk-bundle-1.11.375.jar:/usr/hdp/3.1.4.0-315/hbase/lib/checker-qual-2.8.1.jar:/usr/hdp/3.1.4。。。。。。。（这里依赖太多就省略了）
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:java.library.path=:/usr/hdp/3.1.4.0-315/hadoop/lib/native/Linux-amd64-64:/usr/hdp/3.1.4.0-315/hadoop/lib/native/Linux-amd64-64:/usr/hdp/3.1.4.0-315/hadoop/lib/native
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:java.io.tmpdir=/tmp
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:java.compiler=<NA>
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:os.name=Linux
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:os.arch=amd64
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:os.version=3.10.0-1160.11.1.el7.x86_64
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:user.name=root
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:user.home=/root
2021-07-23 09:25:41,882 INFO  [main] zookeeper.ZooKeeper: Client environment:user.dir=/usr/hdp/3.1.4.0-315/spark2
2021-07-23 09:25:41,885 INFO  [main] zookeeper.ZooKeeper: Initiating client connection, connectString=node01:2181,node02:2181,node03:2181 sessionTimeout=90000 watcher=org.apache.hadoop.hbase.zookeeper.PendingWatcher@604c5de8
HBaseFsck command line options: 
2021-07-23 09:25:41,913 INFO  [main] util.HBaseFsck: Launching hbck
2021-07-23 09:25:41,916 INFO  [main-SendThread(node01:2181)] zookeeper.ClientCnxn: Opening socket connection to server node01/10.3.2.24:2181. Will not attempt to authenticate using SASL (unknown error)
2021-07-23 09:25:41,925 INFO  [main-SendThread(node01:2181)] zookeeper.ClientCnxn: Socket connection established, initiating session, client: /10.3.2.24:58562, server: node01/10.3.2.24:2181
2021-07-23 09:25:41,966 INFO  [main-SendThread(node01:2181)] zookeeper.ClientCnxn: Session establishment complete on server node01/10.3.2.24:2181, sessionid = 0x17aadd367a40a27, negotiated timeout = 60000
2021-07-23 09:25:41,995 INFO  [main] zookeeper.ReadOnlyZKClient: Connect 0x4a11eb84 to node01:2181,node02:2181,node03:2181 with session timeout=90000ms, retries 6, retry interval 1000ms, keepAlive=60000ms
2021-07-23 09:25:42,000 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x4a11eb84] zookeeper.ZooKeeper: Initiating client connection, connectString=node01:2181,node02:2181,node03:2181 sessionTimeout=90000 watcher=org.apache.hadoop.hbase.zookeeper.ReadOnlyZKClient$$Lambda$14/781735981@6b9ac39a
2021-07-23 09:25:42,002 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x4a11eb84-SendThread(node03:2181)] zookeeper.ClientCnxn: Opening socket connection to server node03/10.3.2.26:2181. Will not attempt to authenticate using SASL (unknown error)
2021-07-23 09:25:42,004 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x4a11eb84-SendThread(node03:2181)] zookeeper.ClientCnxn: Socket connection established, initiating session, client: /10.3.2.24:49356, server: node03/10.3.2.26:2181
2021-07-23 09:25:42,051 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x4a11eb84-SendThread(node03:2181)] zookeeper.ClientCnxn: Session establishment complete on server node03/10.3.2.26:2181, sessionid = 0x37aad46c7b71234, negotiated timeout = 60000
Version: 2.0.2.3.1.4.0-315
2021-07-23 09:25:42,797 INFO  [main] util.HBaseFsck: Computing mapping of all store files
.
2021-07-23 09:25:43,501 INFO  [main] util.HBaseFsck: Validating mapping using HDFS state
2021-07-23 09:25:43,502 INFO  [main] util.HBaseFsck: Computing mapping of all link files
.
2021-07-23 09:25:43,691 INFO  [main] util.HBaseFsck: Validating mapping using HDFS state
Number of live region servers: 1
Number of dead region servers: 1
Master: node01,16000,1626086603004
Number of backup masters: 2
Average load: 50.0
Number of requests: 207161
Number of regions: 50
Number of regions in transition: 0
2021-07-23 09:25:44,100 INFO  [main] util.HBaseFsck: Loading regionsinfo from the hbase:meta table

Number of empty REGIONINFO_QUALIFIER rows in hbase:meta: 0
2021-07-23 09:25:44,226 INFO  [main] util.HBaseFsck: getTableDescriptors == tableNames => [SYSTEM.FUNCTION, hbase_test, suntest:t2, USER, suntest:t1, SYSTEM.LOG, atlas_janus, kylin_metadata, test_schema1:t2, SYSTEM.STATS, SUNTEST.USER, hbase:namespace, test_schema1:t1, KYLIN_6OMP0DMLFQ, SYSTEM.CATALOG, ATLAS_ENTITY_AUDIT_EVENTS, SYSTEM.MUTEX, SYSTEM.SEQUENCE]
2021-07-23 09:25:44,228 INFO  [main] zookeeper.ReadOnlyZKClient: Connect 0x1ddd3478 to node01:2181,node02:2181,node03:2181 with session timeout=90000ms, retries 6, retry interval 1000ms, keepAlive=60000ms
2021-07-23 09:25:44,229 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x1ddd3478] zookeeper.ZooKeeper: Initiating client connection, connectString=node01:2181,node02:2181,node03:2181 sessionTimeout=90000 watcher=org.apache.hadoop.hbase.zookeeper.ReadOnlyZKClient$$Lambda$14/781735981@6b9ac39a
2021-07-23 09:25:44,230 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x1ddd3478-SendThread(node02:2181)] zookeeper.ClientCnxn: Opening socket connection to server node02/10.3.2.25:2181. Will not attempt to authenticate using SASL (unknown error)
2021-07-23 09:25:44,232 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x1ddd3478-SendThread(node02:2181)] zookeeper.ClientCnxn: Socket connection established, initiating session, client: /10.3.2.24:43240, server: node02/10.3.2.25:2181
2021-07-23 09:25:44,273 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x1ddd3478-SendThread(node02:2181)] zookeeper.ClientCnxn: Session establishment complete on server node02/10.3.2.25:2181, sessionid = 0x27aa2b0324412c8, negotiated timeout = 60000
2021-07-23 09:25:44,444 INFO  [main] client.ConnectionImplementation: Closing master protocol: MasterService
2021-07-23 09:25:44,445 INFO  [main] zookeeper.ReadOnlyZKClient: Close zookeeper connection 0x1ddd3478 to node01:2181,node02:2181,node03:2181
Number of Tables: 18
2021-07-23 09:25:44,455 INFO  [main] util.HBaseFsck: Loading region directories from HDFS
2021-07-23 09:25:44,472 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x1ddd3478] zookeeper.ZooKeeper: Session: 0x27aa2b0324412c8 closed
2021-07-23 09:25:44,473 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x1ddd3478-EventThread] zookeeper.ClientCnxn: EventThread shut down
..
2021-07-23 09:25:44,696 INFO  [main] util.HBaseFsck: Loading region information from HDFS
.
2021-07-23 09:25:47,212 INFO  [main] util.HBaseFsck: Checking and fixing region consistency
2021-07-23 09:25:47,286 INFO  [main] util.HBaseFsck: Handling overlap merges in parallel. set hbasefsck.overlap.merge.parallel to false to run serially.
Summary:
Table test_schema1:t1 is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table test_schema1:t2 is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table SUNTEST.USER is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table ATLAS_ENTITY_AUDIT_EVENTS is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table SYSTEM.CATALOG is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table USER is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table SYSTEM.SEQUENCE is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table SYSTEM.LOG is okay.
    Number of regions: 32
    Deployed on:  node03,16020,1625705330661
Table SYSTEM.FUNCTION is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table SYSTEM.MUTEX is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
Table SYSTEM.STATS is okay.
    Number of regions: 1
    Deployed on:  node03,16020,1625705330661
0 inconsistencies detected.
Status: OK
2021-07-23 09:25:47,557 INFO  [main] zookeeper.ZooKeeper: Session: 0x17aadd367a40a27 closed
2021-07-23 09:25:47,557 INFO  [main-EventThread] zookeeper.ClientCnxn: EventThread shut down
2021-07-23 09:25:47,557 INFO  [main] client.ConnectionImplementation: Closing master protocol: MasterService
2021-07-23 09:25:47,558 INFO  [main] zookeeper.ReadOnlyZKClient: Close zookeeper connection 0x4a11eb84 to node01:2181,node02:2181,node03:2181
2021-07-23 09:25:47,597 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x4a11eb84] zookeeper.ZooKeeper: Session: 0x37aad46c7b71234 closed
2021-07-23 09:25:47,597 INFO  [ReadOnlyZKClient-node01:2181,node02:2181,node03:2181@0x4a11eb84-EventThread] zookeeper.ClientCnxn: EventThread shut down
```
注：目前该工具好像升级了，可参考：https://www.pianshen.com/article/1862366040/

## 20.hbase中文内容乱码解决：

- shell中使用toString
```
hbase(main):050:0> scan 'test'
ROW                                              COLUMN+CELL
 row-1                                           column=f:c1, timestamp=1587984555307, value=\xE7\xA6\x85\xE5\x85\x8B
 row-2                                           column=f:c2, timestamp=1587984555307, value=HBase\xE8\x80\x81\xE5\xBA\x97
 row-3                                           column=f:c3, timestamp=1587984555307, value=HBase\xE5\xB7\xA5\xE4\xBD\x9C\xE7\xAC\x94\xE8\xAE\xB0
 row-4                                           column=f:c4, timestamp=1587984555307, value=\xE6\x88\x91\xE7\x88\xB1\xE4\xBD\xA0\xE4\xB8\xAD\xE5\x9B\xBD\xEF\xBC\x81
4 row(s) in 0.0190 seconds

hbase(main):051:0> scan 'test', {FORMATTER => 'toString'}
ROW                                              COLUMN+CELL
 row-1                                           column=f:c1, timestamp=1587984555307, value=禅克
 row-2                                           column=f:c2, timestamp=1587984555307, value=HBase老店
 row-3                                           column=f:c3, timestamp=1587984555307, value=HBase工作笔记
 row-4                                           column=f:c4, timestamp=1587984555307, value=我爱你中国！
4 row(s) in 0.0170 seconds

hbase(main):052:0> scan 'test', {FORMATTER => 'toString',LIMIT=>1,COLUMN=>'f:c4'}
ROW                                              COLUMN+CELL
 row-4                                           column=f:c4, timestamp=1587984555307, value=我爱你中国！
1 row(s) in 0.0180 seconds

hbase(main):053:0> scan 'test', {FORMATTER_CLASS => 'org.apache.hadoop.hbase.util.Bytes', FORMATTER => 'toString'}
ROW                                              COLUMN+CELL
 row-1                                           column=f:c1, timestamp=1587984555307, value=禅克
 row-2                                           column=f:c2, timestamp=1587984555307, value=HBase老店
 row-3                                           column=f:c3, timestamp=1587984555307, value=HBase工作笔记
 row-4                                           column=f:c4, timestamp=1587984555307, value=我爱你中国！
4 row(s) in 0.0220 seconds

hbase(main):054:0> scan 'test', {FORMATTER_CLASS => 'org.apache.hadoop.hbase.util.Bytes', FORMATTER => 'toString', COLUMN=>'f:c4'}
ROW                                              COLUMN+CELL
 row-4                                           column=f:c4, timestamp=1587984555307, value=我爱你中国！
1 row(s) in 0.0220 seconds

hbase(main):004:0> scan 'test', {COLUMNS => ['f:c1:toString','f:c2:toString'] }
ROW                                              COLUMN+CELL
 row-1                                           column=f:c1, timestamp=1587984555307, value=禅克
 row-2                                           column=f:c2, timestamp=1587984555307, value=HBase老店
2 row(s) in 0.0180 seconds

hbase(main):003:0> scan 'test', {COLUMNS => ['f:c1:c(org.apache.hadoop.hbase.util.Bytes).toString','f:c3:c(org.apache.hadoop.hbase.util.Bytes).toString'] }
ROW                                              COLUMN+CELL
 row-1                                           column=f:c1, timestamp=1587984555307, value=禅克
 row-3                                           column=f:c3, timestamp=1587984555307, value=HBase工作笔记
2 row(s) in 0.0160 seconds

hbase(main):055:0> scan 'test', {COLUMNS => ['f:c1:toString','f:c4:c(org.apache.hadoop.hbase.util.Bytes).toString'] }
ROW                                              COLUMN+CELL
 row-1                                           column=f:c1, timestamp=1587984555307, value=禅克
 row-4                                           column=f:c4, timestamp=1587984555307, value=我爱你中国！
2 row(s) in 0.0290 seconds

hbase(main):058:0> get 'test','row-2','f:c2:toString'
COLUMN                                           CELL
 f:c2                                            timestamp=1587984555307, value=Get到了吗？好意思不帮我分享嘛~哈哈~
1 row(s) in 0.0070 seconds
```
