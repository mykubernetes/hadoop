HDFS相关指令

http://hadoop.apache.org/docs/r1.0.4/cn/hdfs_shell.html

1、查看集群容量使用情况
```
hdfs dfsadmin –report
```

常用命令实操
1、-help：输出这个命令参数
```
bin/hdfs dfs -help rm
```

2、-ls: 显示目录信息
```
hadoop fs -ls /
```

3、-mkdir：在hdfs上创建目录
```
hadoop fs -mkdir -p /aaa/bbb/cc/dd
```

4、-moveFromLocal从本地剪切粘贴到hdfs
```
hadoop fs -moveFromLocal /home/hadoop/a.txt /aaa/bbb/cc/dd
```

5、-moveToLocal：从hdfs剪切粘贴到本地
```
hadoop fs -moveToLocal /aaa/bbb/cc/dd /home/hadoop/a.txt
```

6、--appendToFile  ：追加一个文件到已经存在的文件末尾
```
hadoop  fs -appendToFile  ./hello.txt  /hello.txt
```
7、-cat ：显示文件内容
```
hadoop  fs -cat /hello.txt
```

8、-tail：显示一个文件的末尾
```
hadoop  fs  -tail  /weblog/access_log.1
```

9、-text：以字符形式打印一个文件的内容
```
hadoop  fs  -text  /weblog/access_log.1
```

10、-chgrp 、-chmod、-chown：linux文件系统中的用法一样，修改文件所属权限
```
hadoop  fs  -chmod  666  /hello.txt
hadoop  fs  -chown  someuser:somegrp   /hello.txt
```

11、-copyFromLocal：从本地文件系统中拷贝文件到hdfs路径去
```
hadoop  fs  -copyFromLocal  ./jdk.tar.gz  /aaa/
```

12、-copyToLocal：从hdfs拷贝到本地
```
hadoop fs -copyToLocal /aaa/jdk.tar.gz
```

13、-cp ：从hdfs的一个路径拷贝到hdfs的另一个路径
```
hadoop  fs  -cp  /aaa/jdk.tar.gz  /bbb/jdk.tar.gz.2
```

14、-mv：在hdfs目录中移动文件
```
hadoop  fs  -mv  /aaa/jdk.tar.gz  /
```

15）-get：等同于copyToLocal，就是从hdfs下载文件到本地
```
hadoop fs -get  /aaa/jdk.tar.gz
```

16）-getmerge  ：合并下载多个文件，比如hdfs的目录 /aaa/下有多个文件:log.1, log.2,log.3,...
```
hadoop fs -getmerge /aaa/log.* ./log.sum
```

17）-put：等同于copyFromLocal
```
hadoop  fs  -put  /aaa/jdk.tar.gz  /bbb/jdk.tar.gz.2
```

18）-rm：删除文件或文件夹
```
hadoop fs -rm -r /aaa/bbb/
```

19）-rmdir：删除空目录
```
hadoop  fs  -rmdir   /aaa/bbb/ccc
```

20）-df ：统计文件系统的可用空间信息
```
hadoop  fs  -df  -h  /
```

21、-du统计文件夹的大小信息
```
hadoop  fs  -du  -s  -h /aaa/*
```

22、-count：统计一个指定目录下的文件节点数量
```
hadoop fs -count /aaa/
```

23、-setrep：设置hdfs中文件的副本数量
```
hadoop fs -setrep 3 /aaa/jdk.tar.gz
```

hadoop jar使用方法

1、grep 方法
```
1、mkdir input
2、cp etc/hadoop/*.xml input/
3、hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar grep input output 'dfs[a-z.]+'
```
2、wordcount 方法
```
1、mkdir wcinput
2、cat wcinput/wc.input 
hadoop
hdfs
yarl
hbase
3、hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar wordcount wcinput/ wcoutput
```	
	
