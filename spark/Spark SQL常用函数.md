# Spark SQL函数

# 一、概述

## 1、来源：

本文总结自spark 2.3.1 API文档 org.apache.spark.sql：object functions；

## 2、使用：

`org.apache.spark.sql.functions`中提供了约两百多个函数，大部分函数与`Hive`中类似，除UDF函数，均可在`SparkSQL`中直接使用；

如果想要用于`Dataframe`和`Dataset`，可导入函数：
```
import org.apache.spark.sql.functions._ 
```
其中，大部分支持Column的函数也支持String类型的列名，这些函数的返回类型基本都是Column。

## 3、函数分类：

- 聚合函数
- 集合函数
- 时间函数
- 数学函数
- 混杂misc函数
- 其他非聚合函数
- 排序函数
- 字符串函数
- UDF函数
- 窗口函数

# 二、函数：

## 1、聚合函数

| 函数 | 作用 |
|------|--- |
| approx_count_distinct | count_distinct近似值 |
| avg | 平均值 |
| collect_list | 聚合指定字段的值到list |
| collect_set | 聚合指定字段的值到set |
| corr | 计算两列的Pearson相关系数 |
| count | 计数 |
| countDistinct | 去重计数 SQL中用法select count(distinct class) |
| covar_pop | 总体协方差（population covariance） |
| covar_samp | 样本协方差（sample covariance） |
| first | 分组第一个元素 |
| last | 分组最后一个元素 |
| grouping | |
| grouping_id | |
| kurtosis | 计算峰态(kurtosis)值 |
| skewness | 计算偏度(skewness) |
| max | 最大值 |
| min | 最小值 |
| mean | 平均值 |
| stddev | 即stddev_samp |
| stddev_samp | 样本标准偏差（sample standard deviation） |
| stddev_pop | 总体标准偏差（population standard deviation） |
| sum | 求和 |
| sumDistinct | 非重复值求和 SQL中用法select sum(distinct class) |
| var_pop | 总体方差（population variance） |
| var_samp | 样本无偏方差（unbiased variance） |
| variance | 即var_samp |

## 2、集合函数

| 函数 | 作用 |
|------|-----|
| array_contains(column,value) | 检查array类型字段是否包含指定元素 |
| explode | 展开array或map为多行 |
| explode_outer | 同explode，但当array或map为空或null时，会展开为null。 |
| posexplode | 同explode，带位置索引。 |
| posexplode_outer | 同explode_outer，带位置索引。 |
| from_json | 解析JSON字符串为StructType or ArrayType，有多种参数形式，详见文档。 |
| to_json | 转为json字符串，支持StructType, ArrayType of StructTypes, a MapType or ArrayType of MapTypes。 |
| get_json_object(column,path) | 获取指定json路径的json对象字符串。 |
| json_tuple(column,fields) | 获取json中指定字段值。 |
| map_keys | 返回map的键组成的array |
| map_values | 返回map的值组成的array |
| size	array | 或 map 的长度 |
| sort_array(e: Column, asc: Boolean) | 将array中元素排序（自然排序），默认asc。 |

## 3、时间函数

| 函数 | 作用 |
|------|------|
| add_months(startDate: Column, numMonths: Int) | 指定日期添加n月 |
| date_add(start: Column, days: Int) | 指定日期之后n天: select date_add(‘2018-01-01’,3) |
| date_sub(start: Column, days: Int) | 指定日期之前n天 |
| datediff(end: Column, start: Column) | 两日期间隔天数 |
| current_date() | 当前日期 |
| current_timestamp() | 当前时间戳，TimestampType类型 |
| date_format(dateExpr: Column, format: String) | 日期格式化 |
| dayofmonth(e: Column) | 日期在一月中的天数，支持 date/timestamp/string |
| dayofyear(e: Column) | 日期在一年中的天数， 支持 date/timestamp/string |
| weekofyear(e: Column) | 日期在一年中的周数， 支持 date/timestamp/string |
| from_unixtime(ut: Column, f: String) | 时间戳转字符串格式 |
| from_utc_timestamp(ts: Column, tz: String) | 时间戳转指定时区时间戳 |
| to_utc_timestamp(ts: Column, tz: String) | 指定时区时间戳转UTF时间戳 |
| hour(e: Column) | 提取小时值 |
| minute(e: Column) | 提取分钟值 |
| month(e: Column) | 提取月份值 |
| quarter(e: Column) | 提取季度 |
| second(e: Column) | 提取秒 |
| year(e: Column) | 提取年 |
| last_day(e: Column) | 指定日期的月末日期 |
| months_between(date1: Column, date2: Column) | 计算两日期差几个月 |
| next_day(date: Column, dayOfWeek: String) | 计算指定日期之后的下一个周一、二…，dayOfWeek区分大小写，只接受 “Mon”, “Tue”, “Wed”, “Thu”, “Fri”, “Sat”, “Sun”。 |
| to_date(e: Column) | 字段类型转为DateType |
| trunc(date: Column, format: String) | 日期截断 |
| unix_timestamp(s: Column, p: String) | 指定格式的时间字符串转时间戳 |
| unix_timestamp(s: Column) | 同上，默认格式为 yyyy-MM-dd HH:mm:ss |
| unix_timestamp() | 当前时间戳(秒),底层实现为unix_timestamp(current_timestamp(), yyyy-MM-dd HH:mm:ss) |
| window(timeColumn: Column, windowDuration: String, slideDuration: String, startTime: String) | 时间窗口函数，将指定时间(TimestampType)划分到窗口 |

## 4、数学函数

| 函数 | 作用 |
|------|-----|
| cos,sin,tan | 计算角度的余弦，正弦 |
| sinh,tanh,cosh | 计算双曲正弦，正切
| acos,asin,atan,atan2 | 计算余弦/正弦值对应的角度 |
| bin | 将long类型转为对应二进制数值的字符串For example, bin(“12”) returns “1100”. |
| bround | 舍入，使用Decimal的HALF_EVEN模式，v>0.5向上舍入，v< 0.5向下舍入，v0.5向最近的偶数舍入。 |
| round(e: Column, scale: Int) | HALF_UP模式舍入到scale为小数点。v>=0.5向上舍入，v< 0.5向下舍入,即四舍五入。 |
| ceil | 向上舍入 |
| floor | 向下舍入 |
| cbrt | Computes the cube-root of the given value. |
| conv(num:Column, fromBase: Int, toBase: Int) | 转换数值（字符串）的进制 |
| log(base: Double, a: Column) | logbase(a)log_{base}(a)logbase(a) |
| log(a: Column) | loge(a)log_e(a)loge(a) |
| log10(a: Column) | log10(a)log_{10}(a)log10(a) |
| log2(a: Column) | log2(a)log_{2}(a)log2(a) |
| log1p(a: Column) | loge(a+1)log_{e}(a+1)loge(a+1) |
| pmod(dividend: Column, divisor: Column) | Returns the positive value of dividend mod divisor. |
| pow(l: Double, r: Column) | rlr^lrl 注意r是列 |
| pow(l: Column, r: Double) | rlr^lrl 注意l是列 |
| pow(l: Column, r: Column) | rlr^lrl 注意r,l都是列 |
| radians(e: Column) | 角度转弧度 |
| rint(e: Column) | Returns the double value that is closest in value to the argument and is equal to a mathematical integer. |
| shiftLeft(e: Column, numBits: Int) | 向左位移 |
| shiftRight(e: Column, numBits: Int) | 向右位移 |
| shiftRightUnsigned(e: Column, numBits: Int) | 向右位移（无符号位） |
| signum(e: Column) | 返回数值正负符号 |
| sqrt(e: Column) | 平方根 |
| hex(column: Column) | 转十六进制 |
| unhex(column: Column) | 逆转十六进制 |

## 5、混杂misc函数

| 函数 | 作用 |
|------|------|
| crc32(e: Column) | 计算CRC32,返回bigint |
| hash(cols: Column*) | 计算 hash code，返回int |
| md5(e: Column) | 计算MD5摘要，返回32位，16进制字符串 |
| sha1(e: Column) | 计算SHA-1摘要，返回40位，16进制字符串 |
| sha2(e: Column, numBits: Int) | 计算SHA-1摘要，返回numBits位，16进制字符串。numBits支持224, 256, 384, or 512. |

## 6、非聚合函数

| 函数 | 作用 |
|-----|------|
| abs(e: Column) | 绝对值 |
| array(cols: Column*) | 多列合并为array，cols必须为同类型 |
| map(cols: Column*) | 将多列组织为map，输入列必须为（key,value)形式，各列的key/value分别为同一类型。 |
| bitwiseNOT(e: Column) | Computes bitwise NOT. |
| broadcast[T](df: Dataset[T]): Dataset[T] | 将df变量广播，用于实现broadcast join。如left.join(broadcast(right), “joinKey”) |
| coalesce(e: Column*) | 返回第一个非空值 |
| col(colName: String) | 返回colName对应的Column |
| column(colName: String) | col函数的别名 |
| expr(expr: String) | 解析expr表达式，将返回值存于Column，并返回这个Column。 |
| greatest(exprs: Column*) | 返回多列中的最大值，跳过Null |
| least(exprs: Column*) | 返回多列中的最小值，跳过Null |
| input_file_name() | 返回当前任务的文件名 ？？ |
| isnan(e: Column) | 检查是否NaN（非数值） |
| isnull(e: Column) | 检查是否为Null |
| lit(literal: Any) | 将字面量(literal)创建一个Column |
| typedLit[T](literal: T)(implicit arg0: scala.reflect.api.JavaUniverse.TypeTag[T]) | 将字面量(literal)创建一个Column，literal支持 scala types e.g.: List, Seq and Map. |
| monotonically_increasing_id() | 返回单调递增唯一ID，但不同分区的ID不连续。ID为64位整型。 |
| nanvl(col1: Column, col2: Column) | col1为NaN则返回col2 |
| negate(e: Column) | 负数，同df.select( -df(“amount”) ) |
| not(e: Column) | 取反，同df.filter( !df(“isActive”) ) |
| rand() | 随机数[0.0, 1.0] |
| rand(seed: Long) | 随机数[0.0, 1.0]，使用seed种子 |
| randn() | 随机数，从正态分布取 |
| randn(seed: Long) | 同上 |
| spark_partition_id() | 返回partition ID |
| struct(cols: Column*) | 多列组合成新的struct column ？？ |
| when(condition: Column, value: Any) | 当condition为true返回value，如people.select(when(people(“gender”) === “male”, 0).when(people(“gender”) === “female”,  1).otherwise(2)) 如果没有otherwise且condition全部没命中，则返回null. |

## 7、排序函数

| 函数 | 作用 |
|------|------|
| asc(columnName: String) | 正序 |
| asc_nulls_first(columnName: String) | 正序，null排最前 |
| asc_nulls_last(columnName: String) | 正序，null排最后 |
| desc(columnName: String) | 逆序 e.g：df.sort(asc(“dept”), desc(“age”)) |
| desc_nulls_first(columnName: String) | 正序，null排最前 |
| desc_nulls_last(columnName: String) | 正序，null排最后 |

## 8、字符串函数

| 函数 | 作用 |
|-----|-------|
| ascii(e: Column) | 计算第一个字符的ascii码 |
| base64(e: Column) | base64转码 |
| unbase64(e: Column) | base64解码 |
| concat(exprs: Column*) | 连接多列字符串 |
| concat_ws(sep: String, exprs: Column*) | 使用sep作为分隔符连接多列字符串 |
| decode(value: Column, charset: String) | 解码 |
| encode(value: Column, charset: String) | 转码，charset支持 ‘US-ASCII’, ‘ISO-8859-1’, ‘UTF-8’, ‘UTF-16BE’, ‘UTF-16LE’, ‘UTF-16’。 |
| format_number(x: Column, d: Int) | 格式化’#,###,###.##'形式的字符串 |
| format_string(format: String, arguments: Column*) | 将arguments按format格式化，格式为printf-style。 |
| initcap(e: Column) | 单词首字母大写 |
| lower(e: Column) | 转小写 |
| upper(e: Column) | 转大写 |
| instr(str: Column, substring: String) | substring在str中第一次出现的位置 |
| length(e: Column) | 字符串长度 |
| levenshtein(l: Column, r: Column) | 计算两个字符串之间的编辑距离（Levenshtein distance） |
| locate(substr: String, str: Column) | substring在str中第一次出现的位置，位置编号从1开始，0表示未找到。 |
| locate(substr: String, str: Column, pos: Int) | 同上，但从pos位置后查找。 |
| lpad(str: Column, len: Int, pad: String) | 字符串左填充。用pad字符填充str的字符串至len长度。有对应的rpad，右填充。 |
| ltrim(e: Column) | 剪掉左边的空格、空白字符，对应有rtrim. |
| ltrim(e: Column, trimString: String) | 剪掉左边的指定字符,对应有rtrim. |
| trim(e: Column, trimString: String) | 剪掉左右两边的指定字符 |
| trim(e: Column) | 剪掉左右两边的空格、空白字符 |
| regexp_extract(e: Column, exp: String, groupIdx: Int) | 正则提取匹配的组 |
| regexp_replace(e: Column, pattern: Column, replacement: Column) | 正则替换匹配的部分，这里参数为列。 |
| regexp_replace(e: Column, pattern: String, replacement: String) | 正则替换匹配的部分 |
| repeat(str: Column, n: Int) | 将str重复n次返回 |
| reverse(str: Column) | 将str反转 |
| soundex(e: Column) | 计算桑迪克斯代码（soundex code）PS:用于按英语发音来索引姓名,发音相同但拼写不同的单词，会映射成同一个码。 |
| split(str: Column, pattern: String) | 用pattern分割str |
| substring(str: Column, pos: Int, len: Int) | 在str上截取从pos位置开始长度为len的子字符串。 |
| substring_index(str: Column, delim: String, count: Int)	 | |
| translate(src: Column, matchingString: String, replaceString: String) | 把src中的matchingString全换成replaceString。 |

## 9、UDF函数

| 函数 | 作用 |
|------|------|
| callUDF(udfName: String, cols: Column*) | 调用UDF |
| udf | 定义UDF |

函数示例：
```
import org.apache.spark.sql._
 
val df = Seq(("id1", 1), ("id2", 4), ("id3", 5)).toDF("id", "value")
val spark = df.sparkSession
spark.udf.register("simpleUDF", (v: Int) => v * v)
df.select($"id", callUDF("simpleUDF", $"value"))
```

##  10、窗口函数

| 函数 | 作用 |
|-----|------|
| cume_dist() | cumulative distribution of values within a window partition |
| currentRow() | returns the special frame boundary that represents the current row in the window partition. |
| rank() | 排名，返回数据项在分组中的排名，排名相等会在名次中留下空位 1,2,2,4。 |
| dense_rank() | 排名，返回数据项在分组中的排名，排名相等会在名次中不会留下空位 1,2,2,3。 |
| row_number() | 行号，为每条记录返回一个数字 1,2,3,4 |
| percent_rank() | returns the relative rank (i.e. percentile) of rows within a window partition. |
| lag(e: Column, offset: Int, defaultValue: Any) | offset rows before the current row |
| lead(e: Column, offset: Int, defaultValue: Any) | returns the value that is offset rows after the current row |
| ntile(n: Int) | returns the ntile group id (from 1 to n inclusive) in an ordered window partition. |
| unboundedFollowing() | returns the special frame boundary that represents the last row in the window partition. |

参考：
- https://cloud.tencent.com/developer/article/1767723
