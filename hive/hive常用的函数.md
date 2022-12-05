# 一、概述
1.查看系统自带的函数

show functions;
```
hive (dyhtest)> show functions;
OK
tab_name
!
!=
$sum0
%
&
*
+
-
/
<
<=
<=>
<>
=
==
>
>=
^
abs
acos
add_months
aes_decrypt
aes_encrypt
and
array
array_contains
ascii
asin
assert_true
assert_true_oom
atan
avg
base64
between
bin
bloom_filter
bround
cardinality_violation
case
cbrt
ceil
ceiling
char_length
character_length
chr
coalesce
collect_list
collect_set
compute_stats
concat
concat_ws
context_ngrams
conv
corr
cos
count
covar_pop
covar_samp
crc32
create_union
cume_dist
current_authorizer
current_database
current_date
current_groups
current_timestamp
current_user
date_add
date_format
date_sub
datediff
day
dayofmonth
dayofweek
decode
degrees
dense_rank
div
e
elt
encode
enforce_constraint
exp
explode
extract_union
factorial
field
find_in_set
first_value
floor
floor_day
floor_hour
floor_minute
floor_month
floor_quarter
floor_second
floor_week
floor_year
format_number
from_unixtime
from_utc_timestamp
get_json_object
get_splits
greatest
grouping
hash
hex
histogram_numeric
hour
if
in
in_bloom_filter
in_file
index
initcap
inline
instr
internal_interval
isfalse
isnotfalse
isnotnull
isnottrue
isnull
istrue
java_method
json_tuple
lag
last_day
last_value
lcase
lead
least
length
levenshtein
like
likeall
likeany
ln
locate
log
log10
log2
logged_in_user
lower
lpad
ltrim
map
map_keys
map_values
mask
mask_first_n
mask_hash
mask_last_n
mask_show_first_n
mask_show_last_n
matchpath
max
md5
min
minute
mod
month
months_between
murmur_hash
named_struct
negative
next_day
ngrams
noop
noopstreaming
noopwithmap
noopwithmapstreaming
not
ntile
nullif
nvl
octet_length
or
parse_url
parse_url_tuple
percent_rank
percentile
percentile_approx
pi
pmod
posexplode
positive
pow
power
printf
quarter
radians
rand
rank
reflect
reflect2
regexp
regexp_extract
regexp_replace
regr_avgx
regr_avgy
regr_count
regr_intercept
regr_r2
regr_slope
regr_sxx
regr_sxy
regr_syy
repeat
replace
replicate_rows
restrict_information_schema
reverse
rlike
round
row_number
rpad
rtrim
second
sentences
sha
sha1
sha2
shiftleft
shiftright
shiftrightunsigned
sign
sin
size
sort_array
sort_array_by
soundex
space
split
sq_count_check
sqrt
stack
std
stddev
stddev_pop
stddev_samp
str_to_map
struct
substr
substring
substring_index
sum
tan
to_date
to_epoch_milli
to_unix_timestamp
to_utc_timestamp
translate
trim
trunc
ucase
udftoboolean
udftobyte
udftodouble
udftofloat
udftointeger
udftolong
udftoshort
udftostring
unbase64
unhex
unix_timestamp
upper
uuid
var_pop
var_samp
variance
version
weekofyear
when
width_bucket
windowingtablefunction
xpath
xpath_boolean
xpath_double
xpath_float
xpath_int
xpath_long
xpath_number
xpath_short
xpath_string
year
|
~
Time taken: 0.037 seconds, Fetched: 289 row(s)
```

2.显示自带的函数的用法

desc function 函数名;
```
hive (dyhtest)> desc function sum;
OK
tab_name
sum(x) - Returns the sum of a set of numbers
```

3.详细显示自带的函数的用法

desc function extended 函数名
```
hive (dyhtest)> desc function extended sum;
OK
tab_name
sum(x) - Returns the sum of a set of numbers
Function class:org.apache.hadoop.hive.ql.udf.generic.GenericUDAFSum
Function type:BUILTIN
Time taken: 0.034 seconds, Fetched: 3 row(s)
```

# 二、常用时间函数

1、unix_timestamp:返回当前或指定时间的时间戳
```
--- 返回当前时间的时间戳
hive (dyhtest)> select unix_timestamp();
unix_timestamp(void) is deprecated. Use current_timestamp instead.
unix_timestamp(void) is deprecated. Use current_timestamp instead.
OK
_c0
1657688794
Time taken: 0.663 seconds, Fetched: 1 row(s)

--- 返回指定时间的时间戳
hive (dyhtest)> select unix_timestamp("2020-10-28",'yyyy-MM-dd');
OK
_c0
1603843200
Time taken: 0.174 seconds, Fetched: 1 row(s)
```

2、rom_unixtime：将时间戳转为日期格式
```
hive (dyhtest)> select from_unixtime(1603843200);
OK
_c0
2020-10-28 00:00:00
Time taken: 0.162 seconds, Fetched: 1 row(s)
```

3、current_date：当前日期
```
hive (dyhtest)>  select current_date;
OK
_c0
2022-07-13
Time taken: 0.18 seconds, Fetched: 1 row(s)
```

4、current_timestamp：当前的日期加时间
```
hive (dyhtest)> select current_timestamp;
OK
_c0
2022-07-13 13:16:52.21
Time taken: 0.151 seconds, Fetched: 1 row(s)
```

5、to_date：抽取日期部分
```
hive (dyhtest)> select to_date('2020-10-28 12:12:12');
OK
_c0
2020-10-28
Time taken: 2.91 seconds, Fetched: 1 row(s)
```

6、year：获取年
```
hive (dyhtest)> select year('2020-10-28 12:12:12');
OK
_c0
2020
Time taken: 0.161 seconds, Fetched: 1 row(s)
```

7、month：获取月
```
hive (dyhtest)> select month('2020-10-28 12:12:12');
OK
_c0
10
Time taken: 0.166 seconds, Fetched: 1 row(s)
```

8、day：获取日
```
hive (dyhtest)> select day('2020-10-28 12:12:12');
OK
_c0
28
Time taken: 0.14 seconds, Fetched: 1 row(s)
```

9、hour：获取时
```
hive (dyhtest)> select hour('2020-10-28 12:13:14');
OK
_c0
12
Time taken: 0.137 seconds, Fetched: 1 row(s)
```

10、minute：获取分
```
hive (dyhtest)> select minute('2020-10-28 12:13:14');
OK
_c0
13
Time taken: 0.133 seconds, Fetched: 1 row(s)
```

11、second：获取秒
```
hive (dyhtest)> select second('2020-10-28 12:13:14');
OK
_c0
14
Time taken: 0.141 seconds, Fetched: 1 row(s)
```

12、weekofyear：当前时间是一年中的第几周
```
hive (dyhtest)> select weekofyear('2020-10-28 12:12:12');
OK
_c0
44
Time taken: 0.154 seconds, Fetched: 1 row(s)
```

13、dayofmonth：当前时间是一个月中的第几天
```
hive (dyhtest)> select dayofmonth('2020-10-28 12:12:12');
OK
_c0
28
Time taken: 0.127 seconds, Fetched: 1 row(s)
```

14、months_between： 两个日期间的月份
```
hive (dyhtest)> select months_between('2020-04-01','2020-10-28');
OK
_c0
-6.87096774
Time taken: 0.133 seconds, Fetched: 1 row(s)
```

15、add_months：日期加减月
```
hive (dyhtest)> select add_months('2020-10-28',-3);
OK
_c0
2020-07-28
Time taken: 0.137 seconds, Fetched: 1 row(s)
```

16、datediff：两个日期相差的天数
```
hive (dyhtest)> select datediff('2020-11-04','2020-10-28');
OK
_c0
7
Time taken: 0.137 seconds, Fetched: 1 row(s)
```

17、date_add：日期加天数
```
hive (dyhtest)> select date_add('2020-10-28',4);
OK
_c0
2020-11-01
Time taken: 0.133 seconds, Fetched: 1 row(s)
```

18、date_sub：日期减天数
```
hive (dyhtest)> select date_sub('2020-10-28',-4);
OK
_c0
2020-11-01
Time taken: 0.14 seconds, Fetched: 1 row(s)
```

19、last_day：日期的当月的最后一天
```
hive (dyhtest)> select last_day('2020-02-30');
OK
_c0
2020-03-31
Time taken: 0.118 seconds, Fetched: 1 row(s)
```

20、date_format(): 格式化日期
```
hive (dyhtest)> select date_format('2020-10-28 12:12:12','yyyy/MM/dd HH:mm:ss');
OK
_c0
2020/10/28 12:12:12
Time taken: 0.127 seconds, Fetched: 1 row(s)
```

# 三、常用取整函数

1、round： 四舍五入
```
--- 四舍 
hive (dyhtest)> select round(3.14);
OK
_c0
3
Time taken: 0.132 seconds, Fetched: 1 row(s)


--- 五入
hive (dyhtest)> select round(3.54);
OK
_c0
4
Time taken: 0.122 seconds, Fetched: 1 row(s)
```

2、ceil： 向上取整
```
hive (dyhtest)> select ceil(3.14);
OK
_c0
4
Time taken: 0.126 seconds, Fetched: 1 row(s)
hive (dyhtest)> select ceil(3.54);
OK
_c0
4
Time taken: 0.122 seconds, Fetched: 1 row(s)
```

3、floor： 向下取整
```
hive (dyhtest)> select floor(3.14);
OK
_c0
3
Time taken: 0.129 seconds, Fetched: 1 row(s)

hive (dyhtest)> select floor(3.54);
OK
_c0
3
Time taken: 0.128 seconds, Fetched: 1 row(s)
```

# 四、常用字符串操作函数

1、upper： 转大写
```
hive (dyhtest)> select upper('low');
OK
_c0
LOW
Time taken: 0.144 seconds, Fetched: 1 row(s)
```

2、lower： 转小写
```
hive (dyhtest)> select lower('LOW');
OK
_c0
low
Time taken: 0.115 seconds, Fetched: 1 row(s)
```

3、length： 长度
```
hive (dyhtest)> select length("atguigu");
OK
_c0
7
Time taken: 0.133 seconds, Fetched: 1 row(s)
```

4、trim： 前后去空格
```
hive (dyhtest)> select trim(" atguigu ");
OK
_c0
atguigu
Time taken: 0.119 seconds, Fetched: 1 row(s)
```

5、lpad： 向左补齐，到指定长度
```
hive (dyhtest)> select lpad('atguigu',9,'g');
OK
_c0
ggatguigu
Time taken: 0.108 seconds, Fetched: 1 row(s)
```


6、rpad： 向右补齐，到指定长度
```
hive (dyhtest)> select rpad('atguigu',9,'g');
OK
_c0
atguigugg
Time taken: 0.119 seconds, Fetched: 1 row(s)
```

7、regexp_replace：使用正则表达式匹配目标字符串，匹配成功后替换！
```
hive (dyhtest)> SELECT regexp_replace('2020/10/25', '/', '-');
OK
_c0
2020-10-25
Time taken: 0.125 seconds, Fetched: 1 row(s)
```

# 五、集合操作

1、size： 集合中元素的个数
```
hive (dyhtest)> select * from test;
OK
test.name	test.friends	test.children	test.address
songsong	["bingbing","lili"]	{"xiao song":18,"xiaoxiao song":19}	{"street":"hui long guan","city":"beijing"}
yangyang	["caicai","susu"]	{"xiao yang":18,"xiaoxiao yang":19}	{"street":"chao yang","city":"beijing"}
Time taken: 0.127 seconds, Fetched: 2 row(s)

--- 返回字段中的元素个数
hive (dyhtest)> select size(friends) from test;
OK
_c0
2
2
Time taken: 0.154 seconds, Fetched: 2 row(s)

```

2、map_keys： 返回map中的key
```
hive (dyhtest)> select map_keys(children) from test;
OK
_c0
["xiao song","xiaoxiao song"]
["xiao yang","xiaoxiao yang"]
Time taken: 0.133 seconds, Fetched: 2 row(s)

```

3、map_values: 返回map中的value
```
hive (dyhtest)> select map_values(children) from test;
OK
_c0
[18,19]
[18,19]
Time taken: 0.143 seconds, Fetched: 2 row(s)

```

4、array_contains: 判断array中是否包含某个元素
```
hive (dyhtest)> select array_contains(friends,'bingbing') from test;
OK
_c0
true
false
Time taken: 0.134 seconds, Fetched: 2 row(s)

```

5、sort_array： 将array中的元素排序
```
hive (dyhtest)> select sort_array(friends) from test;
OK
_c0
["bingbing","lili"]
["caicai","susu"]
Time taken: 0.152 seconds, Fetched: 2 row(s)

```

# 六、多维分析

1、grouping sets:多维分析
```
--- 建表
hive (dyhtest)> create table testgrouping (
              >   id int, 
              >   name string, 
              >   sex string, 
              >   deptno int 
              > )
              > row format delimited fields terminated by ',';
OK
Time taken: 0.51 seconds
--- 准备数据
[atdyh@hadoop102 datas]$ vim group.txt
1001,zhangsan,man,10
1002,xiaohua,female,10
1003,lisi,man,20
1004,xiaohong,female,20

--- 加载数据
hive (dyhtest)> load data local inpath '/opt/module/hive-3.1.2/datas/group.txt' into table testgrouping;
Loading data to table dyhtest.testgrouping
OK
Time taken: 0.322 seconds

```

**demo:**

需求: 统计每个部门各多少人，男女各多少人，每个部门中男女各多少人
```
 hive (dyhtest)> select deptno, sex ,count(id) from testgrouping group by deptno,sex  grouping sets( (deptno,sex), sex , deptno )
           > ;
Query ID = atdyh_20220713140821_8196122b-2013-4264-bb38-6190797d6aa0
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
set mapreduce.job.reduces=<number>
Starting Job = job_1657525216716_0010, Tracking URL = http://hadoop103:8088/proxy/application_1657525216716_0010/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657525216716_0010
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-13 14:08:30,242 Stage-1 map = 0%,  reduce = 0%
2022-07-13 14:08:37,505 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 6.28 sec
2022-07-13 14:08:43,687 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 9.19 sec
MapReduce Total cumulative CPU time: 9 seconds 190 msec
Ended Job = job_1657525216716_0010
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 9.19 sec   HDFS Read: 14667 HDFS Write: 262 SUCCESS
Total MapReduce CPU Time Spent: 9 seconds 190 msec
OK
deptno	sex	_c2
10	NULL	2
20	NULL	2
NULL	female	2
10	female	1
20	female	1
NULL	man	2
10	man	1
20	man	1
Time taken: 22.924 seconds, Fetched: 8 row(s)
```

# 七、空值处理函数

1、NVL：给值为NULL的数据赋值，它的格式是NVL( value，default_value)。它的功能是如果value为NULL，则NVL函数返回default_value的值，否则返回value的值，如果两个参数都为NULL ，则返回NULL。
```
hive (dyhtest)> select ename,nvl(sal,0.0) from emp;
OK
ename	_c1
CLERK	0.0
ALLEN	1600.0
WARD	1250.0
JONES	2975.0
MARTIN	1250.0
BLAKE	2850.0
CLARK	2450.0
SCOTT	3000.0
KING	5000.0
TURNER	1500.0
ADAMS	1100.0
JAMES	950.0
FORD	3000.0
MILLER	1300.0
Time taken: 0.13 seconds, Fetched: 14 row(s)
```

# 八、条件处理函数

1、CASE WHEN THEN ELSE END
```
---数据准备
[atdyh@hadoop102 datas]$ vim emp_sex.txt
悟空	A	男
大海	A	男
宋宋	B	男
凤姐	A	女
婷姐	B	女
婷婷	B	女

--- 建表
hive (dyhtest)> create table emp_sex(
              > name string, 
              > dept_id string, 
              > sex string) 
              > row format delimited fields terminated by "\t";
OK
Time taken: 0.122 seconds

--- 加载数据
hive (dyhtest)> load data local inpath '/opt/module/hive-3.1.2/datas/emp_sex.txt' into table emp_sex
              > ;
Loading data to table dyhtest.emp_sex
OK
Time taken: 0.404 seconds

```

**demo**：计算每个部分的男女各有多少
```
hive (dyhtest)> select 
              >   dept_id,
              >   sum(case sex when '男' then 1 else 0 end) male_count,
              >   sum(case sex when '女' then 1 else 0 end) female_count
              > from 
              >   emp_sex
              > group by
              >   dept_id;
Query ID = atdyh_20220713151659_7eab29e8-5470-461c-a7fc-e57eed7a7b51
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657525216716_0011, Tracking URL = http://hadoop103:8088/proxy/application_1657525216716_0011/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657525216716_0011
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-13 15:17:08,321 Stage-1 map = 0%,  reduce = 0%
2022-07-13 15:17:16,586 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 13.65 sec
2022-07-13 15:17:24,839 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 17.33 sec
MapReduce Total cumulative CPU time: 17 seconds 330 msec
Ended Job = job_1657525216716_0011
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 17.33 sec   HDFS Read: 15130 HDFS Write: 123 SUCCESS
Total MapReduce CPU Time Spent: 17 seconds 330 msec
OK
dept_id	male_count	female_count
A	2	1
B	1	2
Time taken: 27.129 seconds, Fetched: 2 row(s)

```

2、if函数
```
--- 查询用法
--- 使用if函数实现
hive (dyhtest)> select 
              >   dept_Id, 
              >   sum(if(sex='男',1,0))   man, 
              >   sum(if(sex='女',1,0))  female
              > from
              >   emp_sex 
              > group by dept_Id    
              > ;
Query ID = atdyh_20220713152258_067b4217-4cab-4d1c-a641-6cb2e22b050d
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657525216716_0012, Tracking URL = http://hadoop103:8088/proxy/application_1657525216716_0012/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657525216716_0012
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-13 15:23:07,271 Stage-1 map = 0%,  reduce = 0%
2022-07-13 15:23:18,730 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 4.04 sec
2022-07-13 15:23:25,922 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 7.61 sec
MapReduce Total cumulative CPU time: 7 seconds 610 msec
Ended Job = job_1657525216716_0012
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 7.61 sec   HDFS Read: 15226 HDFS Write: 123 SUCCESS
Total MapReduce CPU Time Spent: 7 seconds 610 msec
OK
dept_id	man	female
A	2	1
B	1	2
Time taken: 29.855 seconds, Fetched: 2 row(s)
hive (dyhtest)> 

```

# 九、 拼接函数

1、CONCAT(string A/col, string B/col…)：返回输入字符串连接后的结果，支持任意个输入字符串;
```
hive (dyhtest)> select concat('a','b')
              > ;
OK
_c0
ab
Time taken: 0.218 seconds, Fetched: 1 row(s)

```

2、CONCAT_WS(separator, str1, str2,…)：它是一个特殊形式的 CONCAT()。第一个参数剩余参数间的分隔符。分隔符可以是与剩余参数一样的字符串。如果分隔符是 NULL，返回值也将为 NULL。这个函数会跳过分隔符参数后的任何 NULL 和空字符串。分隔符将被加到被连接的字符串之间;
```
hive (dyhtest)> select concat_ws('-','a','b');
OK
_c0
a-b
Time taken: 0.131 seconds, Fetched: 1 row(s)

```

# 十、 行转列

COLLECT_SET(col)：函数只接受基本数据类型，它的主要作用是将某字段的值进行去重汇总，产生array类型字段。

COLLECT_LIST(col)：函数只接受基本数据类型，它的主要作用是将某字段的值进行汇总，产生array类型字段。
```
--- 准备数据
[atdyh@hadoop102 datas]$ vim person_info.txt
孙悟空	白羊座	A
大海	射手座	A
宋宋	白羊座	B
猪八戒	白羊座	A
凤姐	射手座	A
苍老师	白羊座	B

--- 创建表
hive (dyhtest)> create table person_info(
              > name string, 
              > constellation string, 
              > blood_type string) 
              > row format delimited fields terminated by "\t";
OK
Time taken: 0.299 seconds

```

需求:  
射手座,A 大海|凤姐  
白羊座,A 孙悟空|猪八戒  
白羊座,B 宋宋|苍老师  
```
hive (dyhtest)> select
              >   t1.c_b,  concat_ws('|',collect_set(t1.name)) names
              > from 
              >  (select
              >   name, 
              >   concat_ws(',',constellation,blood_type) c_b
              > from 
              >   person_info)t1
              > group by t1.c_b 
              > ;
Query ID = atdyh_20220713193921_97865dd7-b43d-4442-88d7-99d884fb3bcd
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657525216716_0013, Tracking URL = http://hadoop103:8088/proxy/application_1657525216716_0013/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657525216716_0013
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-13 19:39:30,736 Stage-1 map = 0%,  reduce = 0%
2022-07-13 19:39:38,986 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 4.82 sec
2022-07-13 19:39:45,157 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 9.83 sec
MapReduce Total cumulative CPU time: 9 seconds 830 msec
Ended Job = job_1657525216716_0013
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 9.83 sec   HDFS Read: 9608 HDFS Write: 282 SUCCESS
Total MapReduce CPU Time Spent: 9 seconds 830 msec
OK
t1.c_b	names
射手座,A	大海|凤姐
白羊座,A	孙悟空|猪八戒
白羊座,B	宋宋|苍老师
Time taken: 26.102 seconds, Fetched: 3 row(s)

```

# 十一、 列转行

1、EXPLODE(col)：将hive一列中复杂的array或者map结构拆分成多行。
```
hive (dyhtest)> select * from test;
OK
test.name	test.friends	test.children	test.address
songsong	["bingbing","lili"]	{"xiao song":18,"xiaoxiao song":19}	{"street":"hui long guan","city":"beijing"}
yangyang	["caicai","susu"]	{"xiao yang":18,"xiaoxiao yang":19}	{"street":"chao yang","city":"beijing"}
Time taken: 0.132 seconds, Fetched: 2 row(s)
hive (dyhtest)> select explode(friends) from test;
OK
col
bingbing
lili
caicai
susu
Time taken: 0.129 seconds, Fetched: 4 row(s)

```

2、LATERAL VIEW ：侧写表（虚拟表）

用法：LATERAL VIEW udtf(expression) tableAlias AS columnAlias

解释：用于和split, explode等UDTF一起使用，它能够将一列数据拆成多行数据，在此基础上可以对拆分后的数据进行聚合。
```
--- 数据准备
[atdyh@hadoop102 datas]$ vi movie_info.txt
《疑犯追踪》	悬疑,动作,科幻,剧情
《Lie to me》	悬疑,警匪,动作,心理,剧情
《战狼2》	战争,动作,灾难

--- 建表
hive (dyhtest)> create table movie_info(
              >     movie string, 
              >     category string) 
              > row format delimited fields terminated by "\t";
OK
Time taken: 0.134 seconds

--- 加载数据
hive (dyhtest)> load data local inpath '/opt/module/hive-3.1.2/datas/movie_info.txt' into table movie_info;
Loading data to table dyhtest.movie_info
OK
Time taken: 0.309 seconds

```

需求：  
《疑犯追踪》 悬疑  
《疑犯追踪》 动作  
《疑犯追踪》 科幻  
《疑犯追踪》 剧情  
《Lie to me》 悬疑  
《Lie to me》 警匪  
《Lie to me》 动作  
《Lie to me》 心理  
《Lie to me》 剧情  
《战狼2》 战争  
《战狼2》 动作  
《战狼2》 灾难  
```
hive (dyhtest)> SELECT movie,category_name 
              > FROM movie_info 
              > lateral VIEW
              > explode(split(category,",")) movie_info_tmp  AS category_name ;
OK
movie	category_name
《疑犯追踪》	悬疑
《疑犯追踪》	动作
《疑犯追踪》	科幻
《疑犯追踪》	剧情
《Lie to me》	悬疑
《Lie to me》	警匪
《Lie to me》	动作
《Lie to me》	心理
《Lie to me》	剧情
《战狼2》	战争
《战狼2》	动作
《战狼2》	灾难
Time taken: 0.777 seconds, Fetched: 12 row(s)

```

# 十二、 窗口函数

- OVER()：指定分析函数工作的数据窗口大小，这个数据窗口大小可能会随着行的改变而变化。
- CURRENT ROW：当前行
- n PRECEDING：往前n行数据
- n FOLLOWING：往后n行数据
- UNBOUNDED：起点，
- UNBOUNDED PRECEDING 表示从前面的起点，
- UNBOUNDED FOLLOWING表示到后面的终
- LAG(col,n,default_val)：往前第n行数据 ，如果没有需要给一个默认值
- LEAD(col,n, default_val)：往后第n行数据 ，如果没有需要给一个默认值
- NTILE(n)：把有序窗口的行分发到指定数据的组中，各个组有编号，编号从1开始，对于每一行，NTILE返回此行所属的组的编号。

**注意**：n必须为int类型。

```
--- 准备数据

[atdyh@hadoop102 datas]$ vi business.txt

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

--- 建表 
hive (dyhtest)> create table business(
              > name string, 
              > orderdate string,
              > cost int
              > ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';
OK
Time taken: 4.123 seconds

--- 加载数据
hive (dyhtest)> load data local inpath '/opt/module/hive-3.1.2/datas/business.txt' into table business;
Loading data to table dyhtest.business
OK
Time taken: 1.043 seconds

```

demo1: 查询在2017年4月份购买过的顾客及总人数
```
hive (dyhtest)> SELECT t1.name,COUNT(1) from 
              > (SELECT name ,orderdate,cost from business 
              > WHERE SUBSTR(orderdate,1,7) = '2017-04' ) t1 
              > GROUP  by t1.name;
Query ID = atdyh_20220715183050_92435310-890e-4a9f-a151-8704d8703173
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657877492825_0002, Tracking URL = http://hadoop103:8088/proxy/application_1657877492825_0002/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657877492825_0002
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-15 18:31:03,996 Stage-1 map = 0%,  reduce = 0%
2022-07-15 18:31:14,643 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 5.71 sec
2022-07-15 18:31:20,850 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 9.58 sec
MapReduce Total cumulative CPU time: 9 seconds 580 msec
Ended Job = job_1657877492825_0002
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 9.58 sec   HDFS Read: 15034 HDFS Write: 125 SUCCESS
Total MapReduce CPU Time Spent: 9 seconds 580 msec
OK
t1.name	_c1
jack	1
mart	4
Time taken: 31.466 seconds, Fetched: 2 row(s)

```

demo2：查询顾客的购买明细及所有顾客的月购买总额
```
hive (dyhtest)> select
              >   name, 
              >   orderdate,
              >   cost, 
              >   sum(cost) over(partition by name, substring(orderdate,0,7)) name_month_cost
              > from business;
Query ID = atdyh_20220715203542_65ef7cb7-bfb8-4310-9b42-afd0afebc457
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657877492825_0005, Tracking URL = http://hadoop103:8088/proxy/application_1657877492825_0005/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657877492825_0005
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-15 20:36:08,915 Stage-1 map = 0%,  reduce = 0%
2022-07-15 20:36:17,353 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 9.06 sec
2022-07-15 20:36:27,476 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 15.82 sec
MapReduce Total cumulative CPU time: 15 seconds 820 msec
Ended Job = job_1657877492825_0005
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 15.82 sec   HDFS Read: 14156 HDFS Write: 592 SUCCESS
Total MapReduce CPU Time Spent: 15 seconds 820 msec
OK
name	orderdate	cost	name_month_cost
	NULL	NULL	NULL
jack	2017-01-08	55	111
jack	2017-01-05	46	111
jack	2017-01-01	10	111
jack	2017-02-03	23	23
jack	2017-04-06	42	42
mart	2017-04-13	94	299
mart	2017-04-11	75	299
mart	2017-04-09	68	299
mart	2017-04-08	62	299
neil	2017-05-10	12	12
neil	2017-06-12	80	80
tony	2017-01-04	29	94
tony	2017-01-02	15	94
tony	2017-01-07	50	94
Time taken: 45.638 seconds, Fetched: 15 row(s)


```

demo3：将每个顾客的cost按照日期进行累加
```
hive (dyhtest)> select name,
              >        orderdate,
              >        cost,
              >        sum(cost)
              >            over (partition by name,substring(orderdate, 0, 7) rows between unbounded preceding and current row ) as lj
              > from dyhtest.business;
Query ID = atdyh_20220715205845_ce864615-9d53-4947-b955-a5eff51ed6ea
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657877492825_0007, Tracking URL = http://hadoop103:8088/proxy/application_1657877492825_0007/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657877492825_0007
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-15 20:58:53,913 Stage-1 map = 0%,  reduce = 0%
2022-07-15 20:59:00,171 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 2.59 sec
2022-07-15 20:59:06,392 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 6.97 sec
MapReduce Total cumulative CPU time: 6 seconds 970 msec
Ended Job = job_1657877492825_0007
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 6.97 sec   HDFS Read: 14109 HDFS Write: 590 SUCCESS
Total MapReduce CPU Time Spent: 6 seconds 970 msec
OK


name	orderdate	cost	lj
	NULL	NULL	NULL
jack	2017-01-08	55	55
jack	2017-01-05	46	101
jack	2017-01-01	10	111
jack	2017-02-03	23	23
jack	2017-04-06	42	42
mart	2017-04-13	94	94
mart	2017-04-11	75	169
mart	2017-04-09	68	237
mart	2017-04-08	62	299
neil	2017-05-10	12	12
neil	2017-06-12	80	80
tony	2017-01-04	29	29
tony	2017-01-02	15	44
tony	2017-01-07	50	94
Time taken: 21.829 seconds, Fetched: 15 row(s)


```

```
hive (dyhtest)> 
              > select
              >   name,
              >   orderdate,
              >   cost,
              ---  第一行 到 当前行 累加
              >   sum(cost) over(order by orderdate rows between UNBOUNDED PRECEDING and CURRENT ROW) f_c,
              --- 上一行和当前行累加
              >   sum(cost) over(order by orderdate rows between 1 PRECEDING and CURRENT ROW ) p_c,
              --- 上一行和下一行进行累加
              >   sum(cost) over(order by orderdate rows between 1 PRECEDING and 1 FOLLOWING ) p_n,
              --- 当前行和最后一行进行累加
              >   sum(cost) over(order by orderdate rows between CURRENT ROW and 1 FOLLOWING ) c_n,
              --- 当前行和最后一行进行累加
              >   sum(cost) over(order by orderdate rows between CURRENT ROW and UNBOUNDED FOLLOWING ) c_l
              > from
              >   business;
Query ID = atdyh_20220715211248_8b2bd014-cf68-43c3-8662-6c950bc45525
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657877492825_0008, Tracking URL = http://hadoop103:8088/proxy/application_1657877492825_0008/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657877492825_0008
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-15 21:12:56,816 Stage-1 map = 0%,  reduce = 0%
2022-07-15 21:13:05,459 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 2.22 sec
2022-07-15 21:13:11,670 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 4.35 sec
MapReduce Total cumulative CPU time: 4 seconds 350 msec
Ended Job = job_1657877492825_0008
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 4.35 sec   HDFS Read: 15956 HDFS Write: 811 SUCCESS
Total MapReduce CPU Time Spent: 4 seconds 350 msec
OK
name	orderdate	cost	f_c	p_c	p_n	c_n	c_l
	NULL	NULL	NULL	NULL	10	10	661
jack	2017-01-01	10	10	10	25	25	661
tony	2017-01-02	15	25	25	54	44	651
tony	2017-01-04	29	54	44	90	75	636
jack	2017-01-05	46	100	75	125	96	607
tony	2017-01-07	50	150	96	151	105	561
jack	2017-01-08	55	205	105	128	78	511
jack	2017-02-03	23	228	78	120	65	456
jack	2017-04-06	42	270	65	127	104	433
mart	2017-04-08	62	332	104	172	130	391
mart	2017-04-09	68	400	130	205	143	329
mart	2017-04-11	75	475	143	237	169	261
mart	2017-04-13	94	569	169	181	106	186
neil	2017-05-10	12	581	106	186	92	92
neil	2017-06-12	80	661	92	92	80	80
Time taken: 23.887 seconds, Fetched: 15 row(s)

```

demo4: 需求四: 查询每个顾客上次的购买时间 及 下一次的购买时间
```
hive (dyhtest)> select
              >    name,
              >    cost, 
              >    orderdate c_orderdate,
              >    lag(orderdate ,1 ,'1970-01-01') over(partition by name  order by orderdate) p_orderdate,
              >    lead(orderdate ,1 ,'9999-01-01') over(partition by name  order by orderdate) p_orderdate
              > from 
              >   business;
Query ID = atdyh_20220715211906_c3cd3160-da5c-4313-ae34-a550a0d0c2c0
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657877492825_0009, Tracking URL = http://hadoop103:8088/proxy/application_1657877492825_0009/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657877492825_0009
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-15 21:19:12,078 Stage-1 map = 0%,  reduce = 0%
2022-07-15 21:19:17,209 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 1.78 sec
2022-07-15 21:19:22,344 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 3.93 sec
MapReduce Total cumulative CPU time: 3 seconds 930 msec
Ended Job = job_1657877492825_0009
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 3.93 sec   HDFS Read: 13145 HDFS Write: 870 SUCCESS
Total MapReduce CPU Time Spent: 3 seconds 930 msec
OK
name	cost	c_orderdate	p_orderdate	p_orderdate
	NULL	NULL	1970-01-01	9999-01-01
jack	10	2017-01-01	1970-01-01	2017-01-05
jack	46	2017-01-05	2017-01-01	2017-01-08
jack	55	2017-01-08	2017-01-05	2017-02-03
jack	23	2017-02-03	2017-01-08	2017-04-06
jack	42	2017-04-06	2017-02-03	9999-01-01
mart	62	2017-04-08	1970-01-01	2017-04-09
mart	68	2017-04-09	2017-04-08	2017-04-11
mart	75	2017-04-11	2017-04-09	2017-04-13
mart	94	2017-04-13	2017-04-11	9999-01-01
neil	12	2017-05-10	1970-01-01	2017-06-12
neil	80	2017-06-12	2017-05-10	9999-01-01
tony	15	2017-01-02	1970-01-01	2017-01-04
tony	29	2017-01-04	2017-01-02	2017-01-07
tony	50	2017-01-07	2017-01-04	9999-01-01
Time taken: 17.356 seconds, Fetched: 15 row(s)

```

demo5: 查询前20%时间的订单信息
```
hive (dyhtest)> select 
              >   t1.name, 
              >   t1.orderdate,
              >   t1.cost ,
              >   t1.gid
              > from 
              > (select
              >   name, 
              >   orderdate,
              >   cost, 
              >   ntile(5) over(order by orderdate ) gid
              > from 
              >   business) t1
              > where t1.gid = 1 ; 
Query ID = atdyh_20220715213127_9f73ac1a-51d7-4a7a-92ba-fb327925e5d5
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657877492825_0010, Tracking URL = http://hadoop103:8088/proxy/application_1657877492825_0010/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657877492825_0010
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-15 21:31:39,216 Stage-1 map = 0%,  reduce = 0%
2022-07-15 21:31:46,500 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 2.65 sec
2022-07-15 21:31:52,665 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 6.73 sec
MapReduce Total cumulative CPU time: 6 seconds 730 msec
Ended Job = job_1657877492825_0010
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 6.73 sec   HDFS Read: 13328 HDFS Write: 174 SUCCESS
Total MapReduce CPU Time Spent: 6 seconds 730 msec
OK
t1.name	t1.orderdate	t1.cost	t1.gid
	NULL	NULL	1
jack	2017-01-01	10	1
tony	2017-01-02	15	1
Time taken: 26.068 seconds, Fetched: 3 row(s)

```

总结:
- over(): 会为每条数据都开启一个窗口. 默认的窗口大小就是当前数据集的大小.
- over(partition by …) : 会按照指定的字段进行分区， 将分区字段的值相同的数据划分到相同的区。每个区中的每条数据都会开启一个窗口.每条数据的窗口大小默认为当前分区数据集的大小.
- over(order by …) : 会在窗口中按照指定的字段对数据进行排序.会为每条数据都开启一个窗口,默认的窗口大小为从数据集开始到当前行.
- over(partition by … order by …) :会按照指定的字段进行分区， 将分区字段的值相同的数据划分到相同的区,在每个区中会按照指定的字段进行排序.会为每条数据都开启一个窗口,默认的窗口大小为当前分区中从数据集开始到当前行.
- over(partition by … order by … rows between … and …) : 指定每条数据的窗口大小.

关键字:
- order by : 全局排序 或者 窗口函数中排序.
- distribute by : 分区
- sort by : 区内排序
- cluster by : 分区排序
- partition by : 窗口函数中分区
- partitioned by : 建表指定分区字段
- clustered by : 建表指定分桶字段

# 十三、 窗口函数（排名函数）

- RANK() 排序相同时会重复，总数不会变
- DENSE_RANK() 排序相同时会重复，总数会减少
- ROW_NUMBER() 会根据顺序计算

```
--- 数据准备
[atdyh@hadoop102 datas]$ vi score.txt
孙悟空	语文	87
孙悟空	数学	95
孙悟空	英语	68
大海	语文	94
大海	数学	56
大海	英语	84
宋宋	语文	64
宋宋	数学	86
宋宋	英语	84
婷婷	语文	65
婷婷	数学	85
婷婷	英语	78

```

demo:需求: 按照学科进行排名
```
hive (dyhtest)> select
              >   name, 
              >   subject,
              >   score,
              >   rank() over(partition by subject order by score desc ) rk,
              >   dense_rank() over(partition by subject order by score desc ) drk ,
              >   row_number() over(partition by subject order by score desc ) rn
              > from
              >   score; 
Query ID = atdyh_20220715214237_0c441769-087c-43d2-8d02-5ddf8403428d
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks not specified. Estimated from input data size: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Starting Job = job_1657877492825_0011, Tracking URL = http://hadoop103:8088/proxy/application_1657877492825_0011/
Kill Command = /opt/module/hadoop-3.1.3/bin/mapred job  -kill job_1657877492825_0011
Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
2022-07-15 21:42:43,475 Stage-1 map = 0%,  reduce = 0%
2022-07-15 21:42:48,637 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 1.97 sec
2022-07-15 21:42:53,762 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 4.53 sec
MapReduce Total cumulative CPU time: 4 seconds 530 msec
Ended Job = job_1657877492825_0011
MapReduce Jobs Launched: 
Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 4.53 sec   HDFS Read: 13898 HDFS Write: 669 SUCCESS
Total MapReduce CPU Time Spent: 4 seconds 530 msec
OK
name	subject	score	rk	drk	rn
孙悟空	数学	95	1	1	1
宋宋	数学	86	2	2	2
婷婷	数学	85	3	3	3
大海	数学	56	4	4	4
宋宋	英语	84	1	1	1
大海	英语	84	1	1	2
婷婷	英语	78	3	2	3
孙悟空	英语	68	4	3	4
大海	语文	94	1	1	1
孙悟空	语文	87	2	2	2
婷婷	语文	65	3	3	3
宋宋	语文	64	4	4	4
Time taken: 18.409 seconds, Fetched: 12 row(s)
```

参考：
- https://blog.csdn.net/qq_37232843/article/details/125793731
