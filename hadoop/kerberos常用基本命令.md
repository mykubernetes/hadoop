授权添加yarn账户
```
[root@xxx ~]# kadmin.local 
Authenticating as principal cloudera-scm/admin@JAST.COM with password.
kadmin.local:  addprinc yarn@JAST.COM
WARNING: no policy specified for yarn@JAST.COM; defaulting to no policy
Enter password for principal "yarn@JAST.COM": 
Re-enter password for principal "yarn@JAST.COM": 
Principal "yarn@JAST.COM" created.
kadmin.local:  exit
```

查看当前系统使用的Kerberos账户
```
#使用的 cloudera-scm
[root@xxx ~]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: cloudera-scm/admin@IZHONGHONG.COM
 
Valid starting       Expires              Service principal
2019-08-06T14:45:54  2019-08-07T14:45:54  krbtgt/JAST.COM@JAST.COM
	renew until 2019-08-13T14:45:54
```
> 注意：这里 Expires 是过期时间，即我们使用kinit 授权时候是有有效期的 

有效期设置对应配置文件  /etc/krb5.conf 中的 ticket_lifetime = 24h 参数 （修改时服务端与客户端同时修改）

退出授权 - kdestroy
```
[root@ecs-dbtest-0003 kerberos]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: admin/admin@JAST.COM
 
Valid starting       Expires              Service principal
10/17/2019 10:17:27  10/18/2019 10:17:27  krbtgt/JAST.COM@JAST.COM
        renew until 10/24/2019 10:17:27
[root@ecs-dbtest-0003 kerberos]# kdestroy
[root@ecs-dbtest-0003 kerberos]# klist
klist: No credentials cache found (filename: /tmp/krb5cc_0)
```

使用Kerberos账户
```
[root@xxx ~]# kinit yarn #这里yarn是通过 kadmin.local  addprinc yarn@JAST.COM 创建的
Password for yarn@JAST.COM:   #这里输入密码
```

然后使用root用户读/写/执行hdfs权限即为yarn用户
```
[root@xxx ~]# hdfs dfs -put index.html /tmp
[root@xxx ~]# hdfs dfs -ls /tmp
Found 6 items
drwxrwxrwx   - hdfs   supergroup          0 2019-08-06 15:56 /tmp/.cloudera_health_monitoring_canary_files
drwxr-xr-x   - yarn   supergroup          0 2019-07-17 09:37 /tmp/hadoop-yarn
drwx--x--x   - hbase  supergroup          0 2019-07-01 13:37 /tmp/hbase-staging
drwx-wx-wx   - hive   supergroup          0 2019-07-02 16:16 /tmp/hive
-rw-r--r--   2 yarn   supergroup       2381 2019-08-06 15:57 /tmp/index.html
drwxrwxrwt   - mapred hadoop              0 2019-07-18 21:38 /tmp/logs
```

创建keytab文件
```
[root@xxx jast]# kadmin.local -q "xst -norandkey -k hdfs.keytab hdfs@JAST.COM"
Authenticating as principal hdfs/admin@JAST.COM with password.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type des3-cbc-sha1 added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type arcfour-hmac added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type camellia256-cts-cmac added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type camellia128-cts-cmac added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type des-hmac-sha1 added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@JAST.COM with kvno 1, encryption type des-cbc-md5 added to keytab WRFILE:hdfs.keytab.
```

命令行使用keytab 
```
[root@xxx jast]# kinit -kt hdfs.keytab hdfs@JAST.COM
[root@xxx jast]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: hdfs@JAST.COM
 
Valid starting       Expires              Service principal
2019-08-07T13:35:19  2019-08-08T13:35:19  krbtgt/JAST.COM@JAST.COM
	renew until 2019-08-14T13:35:19
```

创建keytab不同用户，即便密码相同，也不可共用keytab
```
[root@xxx jast]# kinit -kt hdfs.keytab yarn@JAST.COM
kinit: Keytab contains no suitable keys for yarn@JAST.COM while getting initial credentials
```

合并多个 keytab 为一个 keytab
```
[root@xxx jast]# ktutil
ktutil:  rkt hdfs.keytab  #读取多个keytab
ktutil:  rkt yarn.keytab  
ktutil:  wkt hdfs-nb.keytab #合并为一个hdfs-nb.keytab ， 即这个文件可以使用 hdfs 和yarn 的keytab
ktutil:  exit
```

在当前目录可以看到生成的 hdfs-nb.keytab

验证：
```
[root@xxx jast]# kinit -kt hdfs.keytab yarn@JAST.COM   #使用hdfs的keytab，登录yarn用户，报错
kinit: Keytab contains no suitable keys for yarn@JAST.COM while getting initial credentials
[root@xxx jast]# kinit -kt hdfs-nb.keytab yarn@JAST.COM #使用合并的keytab，登录yarn用户，成功
[root@xxx jast]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: yarn@JAST.COM
 
Valid starting       Expires              Service principal
2019-08-07T13:43:06  2019-08-08T13:43:06  krbtgt/JAST.COM@JAST.COM
	renew until 2019-08-14T13:43:06
[root@xxx jast]# kinit -kt hdfs-nb.keytab hdfs@JAST.COM  #使用合并的keytab，登录hdfs用户，成功
[root@xxx jast]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: hdfs@JAST.COM
 
Valid starting       Expires              Service principal
2019-08-07T13:44:19  2019-08-08T13:44:19  krbtgt/JAST.COM@JAST.COM
	renew until 2019-08-14T13:44:19
```

查看keytab内容
```
[root@xxx jast]# klist -k -e hdfs.keytab 
Keytab name: FILE:hdfs.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   1 hdfs@JAST.COM (aes256-cts-hmac-sha1-96) 
   1 hdfs@JAST.COM (aes128-cts-hmac-sha1-96) 
   1 hdfs@JAST.COM (des3-cbc-sha1) 
   1 hdfs@JAST.COM (arcfour-hmac) 
   1 hdfs@JAST.COM (camellia256-cts-cmac) 
   1 hdfs@JAST.COM (camellia128-cts-cmac) 
   1 hdfs@JAST.COM (des-hmac-sha1) 
   1 hdfs@JAST.COM (des-cbc-md5) 

[root@fwqml006 jast]# klist -k -e hdfs-nb.keytab
Keytab name: FILE:hdfs-nb.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   1 hdfs@JAST.COM (aes256-cts-hmac-sha1-96) 
   1 hdfs@JAST.COM (aes128-cts-hmac-sha1-96) 
   1 hdfs@JAST.COM (des3-cbc-sha1) 
   1 hdfs@JAST.COM (arcfour-hmac) 
   1 hdfs@JAST.COM (camellia256-cts-cmac) 
   1 hdfs@JAST.COM (camellia128-cts-cmac) 
   1 hdfs@JAST.COM (des-hmac-sha1) 
   1 hdfs@JAST.COM (des-cbc-md5) 
   1 yarn@JAST.COM (aes256-cts-hmac-sha1-96) 
   1 yarn@JAST.COM (aes128-cts-hmac-sha1-96) 
   1 yarn@JAST.COM (des3-cbc-sha1) 
   1 yarn@JAST.COM (arcfour-hmac) 
   1 yarn@JAST.COM (camellia256-cts-cmac) 
   1 yarn@JAST.COM (camellia128-cts-cmac) 
   1 yarn@JAST.COM (des-hmac-sha1) 
   1 yarn@JAST.COM (des-cbc-md5) 
```

spark授权 启动指定keytab
```
spark-submit --principal hdfs@JAST.COM --keytab hdfs-nb.keytab --jars $(echo lib/*.jar | tr ' ' ',') --class com.jast.test.Test data-filter-1.0-SNAPSHOT.jar 
```

授权添加yarn账户
```
[root@xxx ~]# kadmin.local 
Authenticating as principal cloudera-scm/admin@JAST.COM with password.
kadmin.local:  addprinc yarn@JAST.COM
WARNING: no policy specified for yarn@JAST.COM; defaulting to no policy
Enter password for principal "yarn@JAST.COM": 
Re-enter password for principal "yarn@JAST.COM": 
Principal "yarn@JAST.COM" created.
kadmin.local:  exit
```
