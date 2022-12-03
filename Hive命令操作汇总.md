# 资料
- 高手直接跳转 https://cwiki.apache.org/confluence/display/hive/languagemanual+windowingandanalytics
- mysql基础 https://nyimac.gitee.io/2020/08/11/MySQL%E5%9F%BA%E7%A1%80/
- mysql高级（调优）https://blog.csdn.net/sinat_41567654/article/details/124409995

# 一、Hive基本数据类型

| Hive 数据类型 | Java 数据类型 | 长度 | 例子 |
|--------------|---------------|-----|------|
| TINYINT | byte | 1byte | 有符号整数 | 20 | 
| SMALINT | short | 2byte | 有符号整数 | 20 |
| INT | int | 4byte | 有符号整数 | 20 |
| BIGINT | long | 8byte | 有符号整数 | 20 |
| BOOLEAN | boolean | 布尔类型， true 或者 false | TRUE FALSE |
| FLOAT | float | 单精度浮点数 | 3.14159 |
| DOUBLE | double | 双精度浮点数 | 3.14159 |
| STRING | string | 字符系列。可以指定字 符集。可以使用单引号或者双 引号。 | ‘now is the time ’ “for all good men” |
| TIMESTAMP | | 时间类型 | |
| BINARY | | 字节数组 | |

Hive 的 String 类型相当于数据库的 varchar 类型，该类型是一个可变的字符串，但不能声明其中最多能存储多少个字符，理论上它可以存储 2GB 的字符数。

| 数据类型 | 描述 | 语法示例 |
|---------|------|----------|
| STRUCT | 和 c 语言中的 | struct 类似	struct() 例 如 `struct<street:string, city:string>` |
| MAP | MAP 是一组键-值对元组集合，使用数组表示法可以 访问数据。 | map() 例如 `map<string, int>` |
| ARRAY | 数组是一组具有相同类型和名称的变量的集合。 | Array() 例如 array |

## Demo案例
```
{
    "name": "songsong",
    "friends": [
        "bingbing",
        "lili"
    ], 
    "children": { 
        "xiao song": 18,
        "xiaoxiao song": 19
    }
    "address": { 
        "street": "hui long guan",
        "city": "beijing"
    }
}
```

对应的txt数据
```
songsong,bingbing_lili,xiao song:18_xiaoxiao song:19,hui long guan_beijing
yangyang,caicai_susu,xiao yang:18_xiaoxiao yang:19,chao yang_beijing
```

在Hive上测试
```
create table test2(
name string,
friends array<string>,
children map<string, int>,
address struct<street:string, city:string>
)
row format delimited                    //行的格式定义
fields terminated by ','                //列分隔符
collection items terminated by '_'      //MAP STRUCE和ARRAY 的分隔符（数据分隔符号）
map keys terminated by ':'              //map中的key于value的分隔符
lines terminated by '\n';               //行分隔符
```
字段解释：
- row format delimited fields terminated by ','    //列分隔符
- collection items terminated by '_'      //MAP STRUCE和ARRAY 的分隔符（数据分隔符号）
- map keys terminated by ':'              //map中的key于value的分隔符
- lines terminated by '\n';               //行分隔符


加载本地数据
```
load data local inpath '/opt/module/hive/datas/test.txt' into table test;
```

查询数据
```
hive (default)> select * from test2;
OK
test2.name      test2.friends   test2.children  test2.address
songsong        ["bingbing","lili"]     {"xiao song":18,"xiaoxiao song":19}     {"street":"hui long guan","city":"beijing"}
yangyang        ["caicai","susu"]       {"xiao yang":18,"xiaoxiao yang":19}     {"street":"chao yang","city":"beijing"}
Time taken: 1.819 seconds, Fetched: 2 row(s)

hive (default)> select friends[1],children['xiao song'],address.city from test2 where name="songsong";
OK
_c0     _c1     city
lili    18      beijing
Time taken: 0.584 seconds, Fetched: 1 row(s)
```

## 类型转换

1、隐式类型转换类似java，比较特殊的有：
- 所有整数类型、 FLOAT 和 STRING 类型都可以隐式地转换成 DOUBLE
- TINYINT、 SMALLINT、 INT 都可以转换为 FLOAT
- BOOLEAN 类型不可以转换为任何其它的类型
- CAST(‘1’ AS INT)将把字符串’1’ 转换成整数 1；如果强制类型转换失败，如执行CAST(‘X’ AS INT)，表达式返回空值 NULL

2、可以使用cast操作显示进行数据类型转换

- 列如cast('1' AS INT)将把字符串'1'转换成整数1；如果强制类型转换失败，如执行CAST('X' AS INT),表达式返回空值 NULL。
```
hive (default)> select '1'+2, cast('1'as int) + 2;
OK
_c0     _c1
3.0     3
Time taken: 0.227 seconds, Fetched: 1 row(s)
```

# 二、DDL数据定义

## 2.1、创建数据库
```
CREATE DATABASE [IF NOT EXISTS] database_name
[COMMENT database_comment]
[LOCATION hdfs_path]
[WITH DBPROPERTIES (property_name=property_value, ...)];
```

2.1.1 创建一个数据库，数据库在HDFS上的**`默认存储在hdfs上的路径是/user/hive/warehouse/*.db`**
```
hive (default)> create database db_hive2 
//默认存储路径是/user/hive/warehouse/*.db
location '/db_hive2.db';
```

2.1.2 避免要创建的数据库已经存在错误，增加if not exists 判断。(标准写法)
```
hive (default)> create database db_hive;
FALILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.DDLTask. Database db_hive already exists

hive (default)> create database if not exists db_hive;
```

2.1.3 创建一个数据库，指定数据库在HDFS上存放的位置
```
hive (default)> create database db_hive2 location '/db_hive2.db';
```

## 2.2 查询数据库

2.2.1 显示数据库
```
hive (default)> show databases;
```

2.2.2 过滤显示查询的数据库
```
hive (default)> show databases like 'db_hive*';
```

2.2.3 显示数据库详情
```
hive (default)> desc database db_hive;
```

2.2.4 显示数据库详细信息
```
hive (default)> desc database extended db_hive;
```

2.2.5 切换数据库
```
hive (default)> use db_hive; 
```

## 2.3、修改数据库
```
hive (default)> alter database db_hive set dbproperties('createtime'='20170830');

hive (default)> desc database extended db_hive;
```

## 2.4、删除数据库
```
drop database db_hive2;
drop database if exists db_hive2;

# 数据库不为空强制删除
drop database db_hive cascade;
```

## 2.5、创建表
```
CREATE [EXTERNAL] TABLE [IF NOT EXISTS] table_name
[(col_name data_type [COMMENT col_comment], ...)]
[COMMENT table_comment]
[PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)]
[CLUSTERED BY (col_name, col_name, ...)
[SORTED BY (col_name [ASC|DESC], ...)] INTO num_buckets BUCKETS]
[ROW FORMAT row_format]
[STORED AS file_format]
[LOCATION hdfs_path]
[TBLPROPERTIES (property_name=property_value, ...)]
[AS select_statement]
```
- EXTERNAL 关键字可以让用户创建一个外部表，在建表的同时可以指定一个指向实际数据的路径（LOCATION） ， 在删除表的时候，内部表的元数据和数据会被一起删除，而外部表只删除元数据，不删除数据
- COMMENT：为表和列添加注释。
- PARTITIONED BY 创建分区表
- CLUSTERED BY 创建分桶表
- SORTED BY 不常用， 对桶中的一个或多个列另外排序
- ROW FORMAT
- DELIMITED
  - [FIELDS TERMINATED BY char]
  - [COLLECTION ITEMS TERMINATED BY char]
  - [MAP KEYS TERMINATED BY char]
  - [LINES TERMINATED BY char] | SERDE serde_name [WITH SERDEPROPERTIES (property_name=property_value, property_name=property_value, …)]
  - 用户在建表的时候可以自定义 SerDe 或者使用自带的 SerDe。如果没有指定 ROWFORMAT 或者 ROW FORMAT DELIMITED，将会使用自带的 SerDe。在建表的时候，用户还需要为表指定列，用户在指定表的列的同时也会指定自定义的 SerDe， Hive 通过 SerDe 确定表的具体的列的数据。SerDe 是 Serialize/Deserilize 的简称， hive 使用 Serde 进行行对象的序列与反序列化
- STORED AS 指定存储文件类型。
- 常用的存储文件类型： SEQUENCEFILE（二进制序列文件）、 TEXTFILE（文本）、 RCFILE（列式存储格式文件）。如果文件数据是纯文本，可以使用 STORED AS TEXTFILE。如果数据需要压缩，使用 STORED AS SEQUENCEFILE
- LOCATION ：指定表在 HDFS 上的存储位置。
- AS：后跟查询语句， 根据查询结果创建表，带有数据。
- LIKE 允许用户复制现有的表结构，但是不复制数据

## 2.6、内部表和外部表

（1）内部表

默认创建的表都是所谓的管理表，有时也被称为内部表。因为这种表， Hive 会（或多或少地）控制着数据的生命周期。 Hive 默认情况下会将这些表的数据存储在由配置项 hive.metastore.warehouse.dir(例如， /user/hive/warehouse)所定义的目录的子目录下。

当我们删除一个管理表时， Hive 也会删除这个表中数据。 管理表不适合和其他工具共享数据

（2）外部表

Hive 并非认为其完全拥有这份数据。删除该表并不会删除掉这份数据，不过描述表的元数据信息会被删除掉。

用例：每天将收集到的网站日志定期流入 HDFS 文本文件。在外部表（原始日志表）的基础上做大量的统计分析，用到的中间表、结果表使用内部表存储，数据通过 SELECT+INSERT 进入内部表

## 2.6.1 创建内部表
```
hive (default)> create table if not exists student(
id int, name string
)
row format delimited fields terminated by '\t'
stored as textfile
location '/user/hive/warehouse/student';

hive (default)> create table if not exists student2 as select id, name from student;

hive (default)> desc formatted student2;

hive (default)> dfs -mkdir /student;
hive (default)> dfs -put /opt/module/datas/student.txt /student;
```

## 2.6.2 创建外部表

- `external`关键字
```
hive (default)> create external table if not exists dept(
deptno int,
dname string,
loc int)
row format delimited fields terminated by '\t';

hive (default)> create external table if not exists emp(
empno int,
ename string,
job string,
mgr int,
hiredate string,
sal double,
comm double,
deptno int)
row format delimited fields terminated by '\t';

hive (default)> desc formatted dept;
```

## 2.6.3 内部表和外部表的转化
```
# 修改内部表 student2 为外部表
hive (default)> alter table student2 set tblproperties('EXTERNAL'='TRUE');

# 查询表的类型
hive (default)> desc formatted student2;

# 修改外部表 student2 为内部表
hive (default)> alter table student2 set tblproperties('EXTERNAL'='FALSE');

# 查询表的类型
hive (default)> desc formatted student2;
```
**注意： ('EXTERNAL'='TRUE')和('EXTERNAL'='FALSE’)为固定写法， 区分大小写**


## 2.7、建表时指定字段分隔符
```
hive (default)> create table test(id int,name string) row format delimited fields terminated by ',';
```

## 2.8、重命名表
```
ALTER TABLE table_name RENAME TO new_table_name
```

## 2.9、更新列
```sql
ALTER TABLE table_name CHANGE [COLUMN] col_old_name col_new_name
column_type [COMMENT col_comment] [FIRST|AFTER column_name]

alter table dept change column deptdesc desc string;
```

## 2.10、增加和替换列
```
ALTER TABLE table_name ADD|REPLACE COLUMNS (col_name data_type [COMMENT col_comment], ...)

alter table dept add columns(deptdesc string);
```

## 2.11、删除表
```
drop table dept;
```

# 三、DML数据操作

## 3.1、加载数据
```
hive> load data [local] inpath '数据的 path' [overwrite] into table student [partition (partcol1=val1,…)];
```
- load data:表示加载数据
- local:表示从本地加载数据到 hive 表； 否则从 HDFS 加载数据到 hive 表
- inpath:表示加载数据的路径
- overwrite:表示覆盖表中已有数据，否则表示追加
- into table:表示加载到哪张表
- student:表示具体的表

### 3.1.1 创建表
```
hive (default)> create table student(id string, name string) 
row format delimited fields terminated by '\t';
```

### 3.1.2 load local文件
```
hive (default)> load data local inpath '/opt/module/hive/datas/student.txt' into table default.student;
```

### 3.1.3 load hdfs文件
```
hive (default)> dfs -put /opt/module/hive/data/student.txt /user/atguigu/hive;
hive (default)> load data inpath '/user/atguigu/hive/student.txt' into table default.student;
```

### 3.1.4 overwrite
```
hive (default)> load data inpath '/user/atguigu/hive/student.txt'overwrite into table default.student;
```

## 3.2、插入数据
```
创建一张表
hive (default)> create table student_par(id int, name string) row format delimited fields terminated by '\t';

基本插入数据
hive (default)> insert into table student_par values(1,'wangwu'),(2,'zhaoliu');

基本插入模式（根据单张表查询结果）
hive (default)> insert overwrite table student_par
                select id, name from student where month='201709';
```
- insert into： 以追加数据的方式插入到表或分区， 原有数据不会删除
- insert overwrite： 会覆盖表中已存在的数据
- 注意： insert 不支持插入部分字段


## 3.3、多表插入
```
hive (default)> from student
                insert overwrite table student partition(month='201707')
                select id, name where month='201709'
                insert overwrite table student partition(month='201706')
                select id, name where month='201709';
```

## 3.4、Import 数据到指定 Hive 表中
```
hive> import table student2 from '/user/hive/warehouse/export/student';
```

## 3.5、数据导出

### 3.5.1 导出到本地
```
hive> insert overwrite local directory '/opt/module/hive/data/export/student'
hive> select * from student;
```

### 3.5.2 格式化导出到本地
```
hive> insert overwrite local directory '/opt/module/hive/data/export/student1'
      ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
hive> select * from student;
```

### 3.5.3 导出到 HDFS 上(没有 local)
```
insert overwrite directory '/user/atguigu/student2'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
select * from student;
```

### 3.5.4 hadoop命令导出
```
(hive) dfs -get /user/hive/warehouse/student/student.txt /opt/module/data/export/student3.txt;
```

### 3.5.5 hive导出
```
(shell) bin/hive -e 'select * from default.student;' > /opt/module/hive/data/export/student4.txt;
```

### 3.5.6 导出到hdfs
```
(hive) export table default.student to '/user/hive/warehouse/export/student';
```

## 3.6、清除表

Truncate 只能删除管理表， 不能删除外部表中数据
```
truncate table student;
```

# 四、DQL数据查询
```
SELECT [ALL | DISTINCT] select_expr, select_expr, ...
FROM table_reference
[WHERE where_condition]
[GROUP BY col_list]
[ORDER BY col_list]
[CLUSTER BY col_list
| [DISTRIBUTE BY col_list] [SORT BY col_list]
[LIMIT number]
```
和mysql的查询一致，包括分组，排序，连接操作等都类似

## Like 和 RLike

RLIKE 子句是 Hive 中这个功能的一个扩展，其可以通过 Java 的正则表达式匹配
```
//% 代表零个或多个字符(任意个字符)。_ 代表一个字符。
select * from emp where ename LIKE 'A%';
select * from emp where ename LIKE '_A%';
select * from emp where ename RLIKE '[A]';  
```

分区（Distribute By）

需要控制某个特定行应该到哪个 reducer， 通常是为了进行后续的聚集操作。 distribute by 子句可以做这件事。 distribute by 类似 MR 中 partition（自定义分区）

注意：对于 distribute by 测试，一定要分配多 reduce 进行处理，否则无法看到 distributeby 的效果
```
set mapreduce.job.reduces=3;

insert overwrite local directory '/opt/module/hive/apache-hive-3.1.2-bin/datas/distribute-result' 
select * from emp 
distribute by deptno 
sort by empno desc;
```

- distribute by 的分区规则是根据分区字段的 hash 码与 reduce 的个数进行模除后，余数相同的分到一个区。
- Hive 要求 DISTRIBUTE BY 语句要写在 SORT BY 语句之前

## Cluster By

当 distribute by 和 sorts by 字段相同时，可以使用 cluster by 方式。

cluster by 除了**具有 distribute by 的功能外还兼具 sort by 的功能**。但是排序只能是升序排序， 不能指定排序规则为 ASC 或者 DESC。
```
//等价
select * from emp cluster by deptno;
select * from emp distribute by deptno sort by deptno;
```

# 分区表和分桶表

## 分区表

分区表实际上就是对应一个 HDFS 文件系统上的独立的文件夹，该文件夹下是该分区所有的数据文件。 Hive 中的分区就是分目录，把一个大的数据集根据业务需要分割成小的数据集。在查询时通过 WHERE 子句中的表达式选择查询所需要的指定的分区，这样的查询效率会提高很多

## 创建分区表

分区字段不能是表中已经存在的数据，可以将分区字段看作表的伪列
```
create table dept_partition(
deptno int, 
dname string, 
loc string
)
partitioned by (day string)
row format delimited fields terminated by '\t';
```
加载数据到指定分区中

注意：分区表加载数据时，必须指定分区
```
hive (default)> load data local inpath
'/opt/module/hive/apache-hive-3.1.2-bin/datas/dept_20200401.log' into table dept_partition
partition(day='20200401');
hive (default)> load data local inpath
'/opt/module/hive/apache-hive-3.1.2-bin/datas/dept_20200402.log' into table dept_partition
partition(day='20200402');
hive (default)> load data local inpath
'/opt/module/hive/apache-hive-3.1.2-bin/datas/dept_20200403.log' into table dept_partition
partition(day='20200403');
```


## 增加分区
```
//创建单个分区
hive (default)> alter table dept_partition add partition(day='20200404');
//同时创建多个分区
hive (default)> alter table dept_partition add partition(day='20200405') partition(day='20200406');
```

## 删除分区
```
//删除单个分区
hive (default)> alter table dept_partition drop partition
(day='20200406');
//同时删除多个分区
hive (default)> alter table dept_partition drop partition (day='20200404'), partition(day='20200405');
```

## 查看分区
```
show partitions dept_partition;
```

## 查看分区表结构
```
desc formatted dept_partition;
```

## 二级分区
```
hive (default)> create table dept_partition2(
deptno int, dname string, loc string
)
partitioned by (day string, hour string)
row format delimited fields terminated by '\t';
```

加载数据
```
load data local inpath
'/opt/module/hive/apache-hive-3.1.2-bin/datas//dept_20200401.log' into table
dept_partition2 partition(day='20200401', hour='12');
```


## 上传数据到分区目录并关联的三种方式

### （1）上传数据后修复
```
hive (default)> dfs -mkdir -p
/user/hive/warehouse/mydb.db/dept_partition2/day=20200401/hour=13;
hive (default)> dfs -put /opt/module/datas/dept_20200401.log
/user/hive/warehouse/mydb.db/dept_partition2/day=20200401/hour=13;
```

此时并不能查询，需要修复
```
msck repair table dept_partition2;
```

再次查询
```
select * from dept_partition2 where day='20200401' and hour='13';
```

### （2）上传数据后添加分区
```
hive (default)> dfs -mkdir -p
/user/hive/warehouse/mydb.db/dept_partition2/day=20200401/hour=14;
hive (default)> dfs -put /opt/module/hive/datas/dept_20200401.log
/user/hive/warehouse/mydb.db/dept_partition2/day=20200401/hour=14;
```

添加分区
```
hive (default)> alter table dept_partition2 add partition(day='201709',hour='14')
```

### （3）创建文件夹后 load 数据到分区
```
hive (default)> dfs -mkdir -p
/user/hive/warehouse/mydb.db/dept_partition2/day=20200401/hour=15;
```

上传数据
```
hive (default)> load data local inpath
'/opt/module/hive/datas/dept_20200401.log' into table
dept_partition2 partition(day='20200401',hour='15');
```

# 动态分区

对分区表 Insert 数据时候， 数据库自动会根据分区字段的值， 将数据插入到相应的分区中， Hive 中也提供了类似的机制， 即动态分区(Dynamic Partition)

在加载数据是如果不指定分区会创建默认分区

注意：可能会报错，resourcemanager会随机挑选一台机器load数据，需要确保本地文件存在，如果不存在则报错
```
hive (default)> load data local inpath
'/opt/module/hive/apache-hive-3.1.2-bin/datas//dept_20200401.log' into table
dept_partition;
```



# 参数配置

动态分区开启，默认为true
```
hive.exec.dynamic.partition=true
```

设置为非严格模式（动态分区的模式，默认 strict，表示必须指定至少一个分区为静态分区， nonstrict 模式表示允许所有的分区字段都可以使用动态分区。 ）
```
hive.exec.dynamic.partition.mode=nonstrict
```

在所有MR节点上创建最多多少动态分区
```
hive.exec.max.dynamic.partitions=1000
```

在每个执行 MR 的节点上，最大可以创建多少个动态分区
```
hive.exec.max.dynamic.partitions.pernode=100
```

整个 MR Job 中，最大可以创建多少个 HDFS 文件。默认 100000
```
hive.exec.max.created.files=100000  
```

当有空分区生成时，是否抛出异常。一般不需要设置。默认 false
```
hive.error.on.empty.partition=false  
```

## demo

问题：插入数据数不指定分区如何自动匹配分区字段？

根据最后一个select字段确定动态分区字段
```
//创建分区表
hive (default)> create table dept_partition_dy(id int, name string)
partitioned by (loc int) row format delimited fields terminated by '\t';
//设置动态分区
set hive.exec.dynamic.partition.mode = nonstrict;

//严格模式下必须指定分区
hive (default)> insert into table dept_partition_dy partition(loc) 
select deptno, dname, loc from dept; 

//hadoop3.x新特性，根据最后一个查询分区，不用指定分区
hive (default)> insert into table dept_partition_dy
select deptno, dname, loc from dept; 

//查看目标分区表的分区情况
hive (default)> show partitions dept_partition;
```


# 分桶表

分区提供一个隔离数据和优化查询的便利方式。不过，并非所有的数据集都可形成合理的分区。 对于一张表或者分区， Hive 可以进一步组织成桶，也就是更为细粒度的数据范围划分。

分区针对的是数据的存储路径；分桶针对的是数据文件

示例

创建分桶表
```
create table stu_buck(id int, name string)
clustered by(id)
into 4 buckets
row format delimited fields terminated by '\t';

desc formatted stu_buck;
>Num Buckets: 4
```

加载数据测试，此处报错，原因是之前设置了reduce任务的数量为3，修改为-1
```
set mapreduce.job.reduces=-1;

//上传到hdfs加载，避免本地文件找不到问题
hive (default)> load data inpath '/data/student.data' into table stu_buck;
```

根据结果可知： Hive 的分桶采用对分桶字段的值进行哈希，然后除以桶的个数求余的方式决定该条记录存放在哪个桶当中

# 抽样查询

对于非常大的数据集，有时用户需要使用的是一个具有代表性的查询结果而不是全部结果
```
语法: TABLESAMPLE(BUCKET x OUT OF y)
hive (default)> select * from stu_buck tablesample(bucket 1 out of 4 on id);
```
注意： x 的值必须小于等于 y 的值

# 函数
## 查看函数说明
```
hive> show functions;
hive> desc function upper;
hive> desc function extended upper;  
```

##  NVL
```
给值为 NULL 的数据赋值， 它的格式是 NVL( value， default_value)。它的功能是如果 value 为 NULL， 则 NVL 函数返回 default_value 的值， 否则返回 value 的值， 如果两个参数都为 NULL ， 则返回 NULL  
```

## CASE WHEN THEN ELSE END
```
create table emp_sex(
name string,
dept_id string,
sex string)
row format delimited fields terminated by "\t";

load data local inpath '/opt/module/hive/apache-hive-3.1.2-bin/datas/emp_sex.data' into table emp_sex;

select
dept_id,
sum(case sex when '男' then 1 else 0 end) male_count,
sum(case sex when '女' then 1 else 0 end) female_count
from emp_sex
group by dept_id;
```

## 行转列函数
```
CONCAT(string A/col, string B/col…)
返回输入字符串连接后的结果， 支持任意个输入字符串;

CONCAT_WS(separator, str1, str2,...)
它是一个特殊形式的 CONCAT()。第一个参数剩余参数间的分隔符。分隔符可以是与剩余参数一样的字符串。如果分隔符是 NULL，返回值也将为 NULL。这个函数会跳过分隔符参数后的任何 NULL 和空字符串。分隔符将被加到被连接的字符串之间;
注意: CONCAT_WS must be "string or array<string>“

COLLECT_SET(col)
函数只接受基本数据类型， 它的主要作用是将某字段的值进行去重汇总， 产生 Array 类型字段  
```

测试
```
create table person_info(
name string,
constellation string,
blood_type string)
row format delimited fields terminated by "\t";

load data local inpath "/opt/module/hive/apache-hive-3.1.2-bin/datas/person_info.data" into table person_info;

SELECT 
	t1.c_b,
	CONCAT_WS("|",collect_set(t1.name))
FROM (
	SELECT 
		NAME,
		CONCAT_WS(',',constellation,blood_type) c_b
	FROM person_info
)t1
GROUP BY t1.c_b;

孙悟空	白羊座	A
大海	射手座	A
宋宋	白羊座	B
猪八戒	白羊座	A
凤姐	射手座	A
苍老师	白羊座	B

t1.c_b  _c1
射手座,A        大海|凤姐
白羊座,A        孙悟空|猪八戒
白羊座,B        宋宋|苍老师
```

## 列转行函数
```
EXPLODE(col)： 将 hive 一列中复杂的 Array 或者 Map 结构拆分成多行。

LATERAL VIEW
用法： LATERAL VIEW udtf(expression) tableAlias AS columnAlias
解释： 用于和 split, explode 等 UDTF 一起使用， 它能够将一列数据拆成多行数据， 在此基础上可以对拆分后的数据进行聚合。  
```

测试
```
create table movie_info(
movie string,
category string)
row format delimited fields terminated by "\t";

load data local inpath "/opt/module/hive/apache-hive-3.1.2-bin/datas/movie_info.data" into table movie_info;

SELECT
movie,
category_name
FROM
movie_info
lateral VIEW
explode(split(category,",")) movie_info_tmp AS category_name;

select split(category,",") from movie_info;
OK
_c0
["悬疑","动作","科幻","剧情"]
["悬疑","警匪","动作","心理","剧情"]
["战争","动作","灾难"]

select explode(split(category,",")) from movie_info;
OK
col
悬疑
动作
科幻
剧情
悬疑
警匪
动作
心理
剧情
战争
动作
灾难



《疑犯追踪》	悬疑,动作,科幻,剧情
《Lie to me》	悬疑,警匪,动作,心理,剧情
《战狼2》	战争,动作,灾难

转换为：

《疑犯追踪》    悬疑
《疑犯追踪》    动作
《疑犯追踪》    科幻
《疑犯追踪》    剧情
《Lie to me》   悬疑
《Lie to me》   警匪
《Lie to me》   动作
《Lie to me》   心理
《Lie to me》   剧情
《战狼2》       战争
《战狼2》       动作
《战狼2》       灾难
```

## 窗口函数
```
OVER()： 指定分析函数工作的数据窗口大小，这个数据窗口大小可能会随着行的变而变
CURRENT ROW：当前行
n PRECEDING：往前 n 行数据
n FOLLOWING：往后 n 行数据
UNBOUNDED：起点，
UNBOUNDED PRECEDING 表示从前面的起点，
UNBOUNDED FOLLOWING 表示到后面的终点
LAG(col,n,default_val)：往前第 n 行数据
LEAD(col,n, default_val)：往后第 n 行数据
NTILE(n)：把有序窗口的行分发到指定数据的组中，各个组有编号，编号从 1 开始，对于每一行， NTILE 返回此行所属的组的编号。 注意： n 必须为 int 类型。
```

测试
```
create table business(
name string,
orderdate string,
cost int
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

load data local inpath "/opt/module/hive/apache-hive-3.1.2-bin/datas/bussiness.data" into table business;
```

查询在 2017 年 4 月份购买过的顾客及总人数
```
select 
name,count(*) over()
from business
where substring(orderdate,1,7) = '2017-04'
group by name;
```
可见over的意思就是针对每一行数据，单独限定了计算的范围，例如

查询顾客的购买明细及月购买总额
```
select name,orderdate,cost,sum(cost) over(partition by month(orderdate))
from business;
```

将每个顾客的 cost 按照日期进行累加
```
select name,orderdate,cost,
sum(cost) over() as sample1,--所有行相加
sum(cost) over(partition by name) as sample2,--按 name 分组，组内数据相加
sum(cost) over(partition by name order by orderdate) as sample3,--按 name分组，组内数据累加
sum(cost) over(partition by name order by orderdate rows between
UNBOUNDED PRECEDING and current row ) as sample4 ,--和 sample3 一样,由起点到当前行的聚合
sum(cost) over(partition by name order by orderdate rows between 1
PRECEDING and current row) as sample5, --当前行和前面一行做聚合
sum(cost) over(partition by name order by orderdate rows between 1
PRECEDING AND 1 FOLLOWING ) as sample6,--当前行和前边一行及后面一行
sum(cost) over(partition by name order by orderdate rows between current
row and UNBOUNDED FOLLOWING ) as sample7 --当前行及后面所有行
from business;
```

查看顾客上次的购买时间，上月时间下移
```
select name,orderdate,cost,
lag(orderdate,1,'1900-01-01') over(partition by name order by orderdate )
as time1, lag(orderdate,2) over (partition by name order by orderdate) as
time2
from business;  

name    orderdate       cost    time1   time2
jack    2017-01-01      10      1900-01-01      NULL
jack    2017-01-05      46      2017-01-01      NULL
jack    2017-01-08      55      2017-01-05      2017-01-01
jack    2017-02-03      23      2017-01-08      2017-01-05
jack    2017-04-06      42      2017-02-03      2017-01-08
mart    2017-04-08      62      1900-01-01      NULL
mart    2017-04-09      68      2017-04-08      NULL
mart    2017-04-11      75      2017-04-09      2017-04-08
mart    2017-04-13      94      2017-04-11      2017-04-09
neil    2017-05-10      12      1900-01-01      NULL
neil    2017-06-12      80      2017-05-10      NULL
tony    2017-01-02      15      1900-01-01      NULL
tony    2017-01-04      29      2017-01-02      NULL
tony    2017-01-07      50      2017-01-04      2017-01-02
```

查询前20%时间的订单信息

分成5组按序排列
```
select * from (
select name,orderdate,cost, ntile(5) over(order by orderdate)
from business
) t
where sorted = 1;  
```

## rank

RANK() 排序相同时会重复，总数不会变

DENSE_RANK() 排序相同时会重复，总数会减少

ROW_NUMBER() 会根据顺序计算

例子
```
create table score(
name string,
subject string,
score int)
row format delimited fields terminated by "\t";

load data local inpath '/opt/module/hive/apache-hive-3.1.2-bin/datas/score.data' into table score;

select name,
subject,
score,
rank() over(partition by subject order by score desc) rp,
dense_rank() over(partition by subject order by score desc) drp,
row_number() over(partition by subject order by score desc) rmp
from score;

name    subject score   rp      drp     rmp
孙悟空  数学    95      1       1       1
宋宋    数学    86      2       2       2
婷婷    数学    85      3       3       3
大海    数学    56      4       4       4
宋宋    英语    84      1       1       1
大海    英语    84      1       1       2
婷婷    英语    78      3       2       3
孙悟空  英语    68      4       3       4
大海    语文    94      1       1       1
孙悟空  语文    87      2       2       2
婷婷    语文    65      3       3       3
宋宋    语文    64      4       4       4
```

## 其他常用函数
```
常用日期函数
unix_timestamp:返回当前或指定时间的时间戳	
select unix_timestamp();
select unix_timestamp("2020-10-28",'yyyy-MM-dd');

from_unixtime：将时间戳转为日期格式
select from_unixtime(1603843200);

current_date：当前日期
select current_date;

current_timestamp：当前的日期加时间
select current_timestamp;

to_date：抽取日期部分
select to_date('2020-10-28 12:12:12');

year：获取年
select year('2020-10-28 12:12:12');

month：获取月
select month('2020-10-28 12:12:12');

day：获取日
select day('2020-10-28 12:12:12');

hour：获取时
select hour('2020-10-28 12:12:12');

minute：获取分
select minute('2020-10-28 12:12:12');

second：获取秒
select second('2020-10-28 12:12:12');

weekofyear：当前时间是一年中的第几周
select weekofyear('2020-10-28 12:12:12');

dayofmonth：当前时间是一个月中的第几天
select dayofmonth('2020-10-28 12:12:12');

months_between： 两个日期间的月份
select months_between('2020-04-01','2020-10-28');

add_months：日期加减月
select add_months('2020-10-28',-3);

datediff：两个日期相差的天数
select datediff('2020-11-04','2020-10-28');

date_add：日期加天数
select date_add('2020-10-28',4);

date_sub：日期减天数
select date_sub('2020-10-28',-4);

last_day：日期的当月的最后一天
select last_day('2020-02-30');

date_format(): 格式化日期
select date_format('2020-10-28 12:12:12','yyyy/MM/dd HH:mm:ss');

常用取整函数
round： 四舍五入
select round(3.14);
select round(3.54);

ceil：  向上取整
select ceil(3.14);
select ceil(3.54);

floor： 向下取整
select floor(3.14);
select floor(3.54);

常用字符串操作函数
upper： 转大写
select upper('low');

lower： 转小写
select lower('low');

length： 长度
select length("atguigu");

trim：  前后去空格
select trim(" atguigu ");

lpad： 向左补齐，到指定长度
select lpad('atguigu',9,'g');

rpad：  向右补齐，到指定长度
select rpad('atguigu',9,'g');

regexp_replace：使用正则表达式匹配目标字符串，匹配成功后替换！
SELECT regexp_replace('2020/10/25', '/', '-');

集合操作
size： 集合中元素的个数
select size(friends) from test3;

map_keys： 返回map中的key
select map_keys(children) from test3;

map_values: 返回map中的value
select map_values(children) from test3;

array_contains: 判断array中是否包含某个元素
select array_contains(friends,'bingbing') from test3;

sort_array： 将array中的元素排序
select sort_array(friends) from test3;

grouping_set:多维分析
```

## 自定义函数

当 Hive 提供的内置函数无法满足你的业务处理需要时， 此时就可以考虑使用用户自定义函数（UDF： user-defined function）

类比mysql中的函数定义

自定义函数类别分为以下三种：
- UDF（User-Defined-Function）一进一出
- UDAF（User-Defined Aggregation Function）聚集函数， 多进一出，类似于： count/max/min
- UDTF（User-Defined Table-Generating Functions）一进多出，如 lateral view explode()

基本步骤

- 继承 Hive 提供的类
  - org.apache.hadoop.hive.ql.udf.generic.GenericUDF
  - org.apache.hadoop.hive.ql.udf.generic.GenericUDTF;
- 实现类中的抽象方法
- 在 hive 的命令行窗口创建函数
  - 添加 jar add jar linux_jar_path
  - 创建 function
  - create [temporary] function [dbname.]function_name AS class_name;
- 在 hive 的命令行窗口删除函数
  - drop [temporary] function [if exists] [dbname.]function_name;

demo实现一个计算字符串程度的函数
```
public class MyFunctionLength extends GenericUDF {

	@Override
	public Object evaluate(DeferredObject[] arg0) throws HiveException {
		if (arg0[0].get() == null) {
			return 0;
		}
		return arg0[0].get().toString().length();
	}

	@Override
	public String getDisplayString(String[] arg0) {
		return "null";
	}

	@Override
	public ObjectInspector initialize(ObjectInspector[] arg0) throws UDFArgumentException {
		if (arg0.length != 1) {
			throw new UDFArgumentLengthException("Input Args Length Error!!!");
		}
		return PrimitiveObjectInspectorFactory.javaIntObjectInspector;
	}
}
```

打成 jar 包上传到服务器/opt/module/data/myudf.jar

将 jar 包添加到 hive 的 classpath
```
hive (default)> add jar /opt/module/data/myudf.jar;
```

创建临时函数与开发好的 java class 关联
```
hive (default)> create temporary function my_len as "com.atguigu.hive.MyStringLength";
```

在 hql 中使用自定义的函数
```
hive (default)> select ename,my_len(ename) ename_len from emp;  
```

## 压缩

参考https://blog.csdn.net/sinat_41567654/article/details/124307217

查看本机压缩依赖，hadoop没有snappy的依赖文件

需要重新编译hadoop，参考https://blog.csdn.net/qq_26076091/article/details/120216333
```
hadoop checknative

Native library checking:
hadoop:  true /opt/module/hadoop-3.1.3/lib/native/libhadoop.so.1.0.0
zlib:    true /lib64/libz.so.1
zstd  :  false
snappy:  false
lz4:     true revision:10301
bzip2:   true /lib64/libbz2.so.1
```

在hive中开启 Map 输出阶段压缩
```
开启 hive 中间传输数据压缩功能
set hive.exec.compress.intermediate=true;
开启 mapreduce 中 map 输出压缩功能
set mapreduce.map.output.compress=true;
设置 mapreduce 中 map 输出数据的压缩方式
set mapreduce.map.output.compress.codec = org.apache.hadoop.io.compress.SnappyCodec;hive (default)>set mapreduce.map.output.compress.codec = org.apache.hadoop.io.compress.BZip2Codec;
执行查询语句
 select count(ename) name from emp;
```

开启 Reduce 输出阶段压缩
```
开启 hive 最终输出数据压缩功能
set hive.exec.compress.output=true;
开启 mapreduce 最终输出数据压缩
set mapreduce.output.fileoutputformat.compress=true;
设置 mapreduce 最终数据输出压缩方式
set mapreduce.output.fileoutputformat.compress.codec = org.apache.hadoop.io.compress.SnappyCodec;
set mapreduce.output.fileoutputformat.compress.codec = org.apache.hadoop.io.compress.BZip2Codec;
设置 mapreduce 最终数据输出压缩为块压缩
 set mapreduce.output.fileoutputformat.compress.type=BLOCK;
测试一下输出结果是否是压缩文件
 insert overwrite local directory '/opt/module/data/distribute-result' 
select * from emp distribute by deptno sort by empno desc;

//输出文件格式为bz2
hadoop26:/opt/module/data/distribute-result$ ls
000000_0.bz2
```

## 文件存储格式
Hive 支持的存储数据的格式主要有： TEXTFILE 、 SEQUENCEFILE、 ORC、 PARQUET。

TEXTFILE 和 SEQUENCEFILE 的存储格式都是基于行存储的；

ORC 和 PARQUET 是基于列式存储的



## TextFile 格式
默认格式，数据不做压缩，磁盘开销大，数据解析开销大。可结合 Gzip、 Bzip2 使用，但使用 Gzip 这种方式， hive 不会对数据进行切分，从而无法对数据进行并行操作。

## Orc 格式
Orc (Optimized Row Columnar)是 Hive 0.11 版里引入的新的存储格式


- Index Data：一个轻量级的 index，默认是每隔 1W 行做一个索引。这里做的索引只是记录某行的各字段在 Row Data 中的 offset。
- Row Data：存的是具体的数据，先取部分行，然后对这些行按列进行存储。 对每个列进行了编码，分成多个 Stream 来存储。
- Stripe Footer：存各个 Stream 的类型，长度等信息。
- 每个文件有一个 File Footer，这里面存的是每个 Stripe 的行数，每个 Column 的数据类型信息等
- 每个文件的尾部是一个 PostScript，这里面记录了整个文件的压缩类型以及FileFooter 的长度信息等。
- 在读取文件时，会 seek 到文件尾部读 PostScript，从里面解析到File Footer 长度，再读 File Footer，从里面解析到各个 Stripe 信息，再读各个 Stripe，即从后往前读

## Parquet 格式

Parquet 文件是以二进制方式存储的，所以是不可以直接读取的，文件中包括该文件的数据和元数据， 因此 Parquet 格式文件是自解析的
- 行组(Row Group)：每一个行组包含一定的行数（对照orc的stripe），在一个 HDFS 文件中至少存储一个行组，类似于 orc 的 stripe 的概念。
- 列块(Column Chunk)：在一个行组中每一列保存在一个列块中，行组中的所有列连续的存储在这个行组文件中。一个列块中的值都是相同类型的，不同的列块可能使用不同的算法进行压缩。
- 页(Page)：每一个列块划分为多个页，一个页是最小的编码的单位，在同一个列块的不同页可能使用不同的编码方式。
- 通常情况下，在存储 Parquet 数据的时候会按照 Block 大小设置行组的大小，由于一般情况下每一个 Mapper 任务处理数据的最小单位是一个 Block，这样可以把每一个行组由一个 Mapper 任务处理，增大任务执行并行度。

一个文件中可以存储多个行组，文件的首位都是该文件的 Magic Code，用于校验它是否是一个 Parquet 文件

Footer length 记录了文件元数据的大小，通过该值和文件长度可以计算出元数据的偏移量，文件的元数据中包括每一个行组的元数据信息和该文件存储数据的 Schema 信息。除了文件中每一个行组的元数据，每一页的开始都会存储该页的元数据，在 Parquet 中，有三种类型的页： 数据页、字典页和索引页。数据页用于存储当前行组中该列的值，字典页存储该列值的编码字典，每一个列块中最多包含一个字典页，索引页用来存储当前行组下该列的索引，目前 Parquet 中还不支持索引页

格式对比

存储文件大小：ORC > Parquet > textFile

查询速度 ：三者类似

# 存储和压缩结合

| Key | Default | Notes |
|-----|---------|-------|
| orc.compress | ZLIB | high level compression (one of NONE, ZLIB, SNAPPY) |

例如，创建一个 ZLIB 压缩的 ORC 存储方式
```
create table log_orc_zlib(
track_time string,
url string,
session_id string,
referer string,
ip string,
end_user_id string,
city_id string
)
row format delimited fields terminated by '\t'
stored as orc
tblproperties("orc.compress"="ZLIB");  
```

# 材料

练习数据汇总

student
```
1001	ss1
1002	ss2
1003	ss3
1004	ss4
1005	ss5
1006	ss6
1007	ss7
1008	ss8
1009	ss9
1010	ss10
1011	ss11
1012	ss12
1013	ss13
1014	ss14
1015	ss15
1016	ss16
```

emp
```
7369	SMITH	CLERK	7902	1980-12-17	800.00	20
7499	ALLEN	SALESMAN	7698	1981-2-20	1600.00	300.00	30
7521	WARD	SALESMAN	7698	1981-2-22	1250.00	500.00	30
7566	JONES	MANAGER	7839	1981-4-2	2975.00	20
7654	MARTIN	SALESMAN	7698	1981-9-28	1250.00	1400.00	30
7698	BLAKE	MANAGER	7839	1981-5-1	2850.00	30
7782	CLARK	MANAGER	7839	1981-6-9	2450.00	10
7788	SCOTT	ANALYST	7566	1987-4-19	3000.00	20
7839	KING	PRESIDENT	1981-11-17	5000.00	10
7844	TURNER	SALESMAN	7698	1981-9-8	1500.00	0.00	30
7876	ADAMS	CLERK	7788	1987-5-23	1100.00	20
7900	JAMES	CLERK	7698	1981-12-3	950.00	30
7902	FORD	ANALYST	7566	1981-12-3	3000.00	20
7934	MILLER	CLERK	7782	1982-1-23	1300.00	10
```

dept
```
10	ACCOUNTING	1700
20	RESEARCH	1800
30	SALES	1900
40	OPERATIONS	1700
```

location
```
1700  Beijing
1800  London
1900  Tokyo
```

depy_xxxx.log
```
dept_20200401.log
10  ACCOUNTING  1700
20  RESEARCH  1800
dept_20200402.log
30  SALES  1900
40  OPERATIONS  1700
dept_20200403.log
50  TEST  2000
60  DEV	1900
```

emp_sex
```
悟空	A	男
大海	A	男
宋宋	B	男
凤姐	A	女
婷姐	B	女
婷婷	B	女
```

bussiness.data
```
jack,2017-01-01,10
tony,2017-01-02,15
jack,2017-02-03,23
tony,2017-01-04,29
jack,2017-01-05,46
jack,2017-04-06,42
tony,2017-01-07,50
jack,2017-01-08,55
mart,2017-04-08,62
mart,2017-04-09,68
neil,2017-05-10,12
mart,2017-04-11,75
neil,2017-06-12,80
mart,2017-04-13,94
```

score
```
孙悟空 语文 87
孙悟空 数学 95
孙悟空 英语 68
大海 语文 94
大海 数学 56
大海 英语 84
宋宋 语文 64
宋宋 数学 86
宋宋 英语 84
婷婷 语文 65
婷婷 数学 85
婷婷 英语 78
```

参考：
- https://blog.csdn.net/sinat_41567654/article/details/124413209
