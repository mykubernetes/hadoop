# 一 .前言

本文主要记录HDFS如何开启Kerberos. Kerberos如何安装请参考文章 Kerberos 安装&使用

## 1.1. 环境说明

| 组件 | 版本 |
|------|-----|
| 操作系统 | CentOS 7.6 |
| JDK	JDK | 1.8.0_161+ [低版本需要安装JCE!!!] |
| Hadoop | 3.1.3 |
| Kerberos | krb5 , 安装参考Kerberos 安装&使用 |

## 1.2. 服务规划

规划需要启动HDFS所需要的用户&凭证信息. (当然也可以用一个.)

为了节约时间,我就统一使用hdfs用户进行安装,用户组为hadoop。因为就一个master01节点, 所以凭证信息统一使用`hdfs/master01@EXAMPLE.COM`

- 参考的服务&凭证如下:

| 组件服务 | 名称 |
|---------|------|
| namenode | nn |
| secondarynamenode | sn |
| datanode | dn |
| resourcemanager | rm |
| nodemanager | nm |
| jobhistoryserver | jhs |
| https | http |
| hive | hive |

## 1.3. 安装Kerberos环境

Kerberos环境需要提前安装, 安装文档参考 : Kerberos 安装&使用

## 1.4. 配置环境变量

修改/etc/profile文件.
```
新增内容:
export JAVA_HOME=/opt/tools/jdk1.8.0_181
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

export HADOOP_HOME=/opt/tools/hadoop-3.1.3
export PATH=$PATH:$HADOOP_HOME/bin

export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$PATH:$HADOOP_CONF_DIR

export HADOOP_USER_NAME=root
export PATH=$PATH:$HADOOP_USER_NAME

export HADOOP_CLASSPATH=/opt/tools/hadoop-3.1.3/share/hadoop
export PATH=$PATH:$HADOOP_CLASSPATH

export HADOOP_MAPRED_HOME=/opt/tools/hadoop-3.1.3
export PATH=$PATH:$HADOOP_MAPRED_HOME/bin
```

# 二 .安装HDFS

至此，Kerberos已经安装完成，现在需要配置Hadoop集群，针对Kerberos进行设置Kerberos如何安装请参考文章 Kerberos 安装&使用

## 2.1. 添加用户

在各个物理机上创建HDFS相关的用户.

[因为我直接使用hdfs用户安装, 所以下面的步骤就直接创建hdfs用户就可以了]
```
groupadd hadoop;
useradd hdfs -g hadoop -p hdfs;
useradd hive -g hadoop -p hive;
useradd yarn -g hadoop -p yarn;
useradd mapred -g hadoop -p mapred
```

记得设置文件的权限,并且切换用户为hdfs进行安装
```
cd /opt/tools
chown -R hdfs:hadoop ./hadoop-3.1.3/


su -l hdfs

```

## 2.2. 配置HDFS相关的Kerberos账户

Hadoop需要Kerberos来进行认证，以启动服务来说，在后面配置 hadoop 的时候我们会给对应服务指定一个Kerberos的账户，比如 namenode 运行在master01机器上，我们可能将 namenode指定给了`nn/master01@HENGHE.COM`这个账户， 那么 想要启动 namenode 就必须认证这个账户才可以。

因为我计划用hdfs用户安装hdfs所以就直接创建一个hdfs的租户就可以了.

### 2.2.1. 创建keytab存放目录

在每个节点执行
```
 mkdir -p /opt/keytab
```

### 2.2.2. 配置master01上面运行的服务对应的Kerberos账户

在每台机器上构建kerberos用户&导出凭证
```
# 进入kadmin
kadmin.local

# 查看用户
listprincs

# 创建用户
addprinc -randkey hdfs/master01@HENGHE.COM

# 导出keytab文件
ktadd -k /opt/keytab/hdfs.keytab hdfs/master01@HENGHE.COM
```

### 2.2.3. 权限设置

需要注意keytab 的权限, 因为我是使用root用户安装,所以不做操作.

- 参考指令
在master01上将刚刚得到的 keytab文件全部设置:
```
chown hdfs:hadoop hdfs.keytab
```
以及
```
chmod 400 hdfs.keytab
```

### 2.2.4. 编译源码构建Linux-Container-executor

> 如果只安装HDFS可以忽略掉本步骤.

Kerberos需要使用基于cgroup工作的一个名为Linux-container-executer的容器来运行YARN任务，这个容器需要我们自己编译源码来构建出来如果编译不出来可以在网络上找找, 编译步骤就不详细说明了.

- 要安装 protobuf-2.5.0 (截止到hadoop的3.2.1版本,必须使用protobuf-2.5.0版本,否则报错.)
```
./configure
make
make install
```

- 编译containerexecutor
```
cd $HADOOP_HOME/src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoopyarn-server-nodemanager

mvn package -Pdist,native -DskipTests -Dtar -Dcontainerexecutor.conf.dir=/opt/yarn-executor
```
记得编译好之后,将container-executor同步到各个节点的bin目录下.

### 2.2.5. 设置 hadoop 需要使用的各个目录的权限

yarn的目录权限下面的配置没做处理.
```
# 设置全局变量
export HADOOP_HOME=/opt/tools/hadoop-3.1.3
export DFS_NAMENODE_NAME_DIR=$HADOOP_HOME/data/namenode
export DFS_DATANODE_DATA_DIR=$HADOOP_HOME/data/hdfs/data


# 设置整体目录权限
chgrp -R hadoop $HADOOP_HOME
chown -R hdfs:hadoop $HADOOP_HOME
chown root:hadoop $HADOOP_HOME

chmod 755 -R $HADOOP_HOME/etc/hadoop/*

# [重要] yarn 相关的container-executor配置 
chown root:hadoop $HADOOP_HOME/etc
chown root:hadoop $HADOOP_HOME/etc/hadoop
chown root:hadoop $HADOOP_HOME/etc/hadoop/container-executor.cfg
chown root:hadoop $HADOOP_HOME/bin/container-executor
chown root:hadoop $HADOOP_HOME/bin/test-container-executor
chmod 6050 $HADOOP_HOME/bin/container-executor
chown 6050 $HADOOP_HOME/bin/test-container-executor

# 设置HDFS数据目录权限
chown -R hdfs:hadoop $DFS_DATANODE_DATA_DIR
chown -R hdfs:hadoop $DFS_NAMENODE_NAME_DIR

chmod 700 $DFS_DATANODE_DATA_DIR
chmod 700 $DFS_NAMENODE_NAME_DIR
```

下表列出了HDFS和 local fileSystem （在所有节点上）的各种路径以及建议的权限：

| Filesystem | Path | User:Group | Permissions |
|------------|------|------------|-------------|
| local | dfs.namenode.name.dir | hdfs:hadoop | drwx------ |
| local | dfs.datanode.data.dir | hdfs:hadoop | drwx------ |
| local | $HADOOP_LOG_DIR | hdfs:hadoop | drwxrwxr-x |
| local | $YARN_LOG_DIR | yarn:hadoop | drwxrwxr-x |
| local | yarn.nodemanager.local-dirs | yarn:hadoop | drwxr-xr-x |
| local | yarn.nodemanager.log-dirs | yarn:hadoop | drwxr-xr-x |
| local | container-executor | root:hadoop | –Sr-s–* |
| local | conf/container-executor.cfg | root:hadoop | r-------* |
| hdfs | / | hdfs:hadoop | drwxr-xr-x |
| hdfs | /tmp | hdfs:hadoop | drwxrwxrwxt |
| hdfs | /user | hdfs:hadoop | drwxr-xr-x |
| hdfs | yarn.nodemanager.remote-app-log-dir | yarn:hadoop | drwxrwxrwxt |
| hdfs | mapreduce.jobhistory.intermediate-done-dir | mapred:hadoop | drwxrwxrwxt |
| hdfs | mapreduce.jobhistory.done-dir | mapred:hadoop | drwxr-x— |

## 2.3. 配置hadoop的 lib/native(本地运行库)

Hadoop是使用Java语言开发的，但是有一些需求和操作并不适合使用java，所以就引入了本地库（Native Libraries）的概念，通过本地库，Hadoop可以更加高效地执行某一些操作。

- 存放目录:
```
$HADOOP_HOME/lib/native
```
具体怎么搞native 网上有现成的找找. 不做具体赘述.

## 2.4. 设置 HDFS 的配置文件

### 2.4.1. sbin/ [start/stop]-dfs.sh

> 非root账户操作,忽略本小结

启动的时候,如果想使用root账户用sbin/ [start/stop]-dfs.sh 脚本启动. 需要做一些配置

修改sbin/ [start/stop]-dfs.sh , 在脚本的开头加入指令:
```
HDFS_DATANODE_USER=root
HADOOP_SECURE_DN_USER=root
HDFS_NAMENODE_USER=root
HDFS_SECONDARYNAMENODE_USER=root
```

### 2.4.2. hadoop-env.sh
```
# 设置JDK 路径请根据具体自己配置的路径修改
export JAVA_HOME=/opt/tools/jdk1.8.0_181
```

### 2.4.3. yarn-env.sh
```
# 设置JDK 路径请根据具体自己配置的路径修改
export JAVA_HOME=/opt/tools/jdk1.8.0_181
```

### 2.4.4. mapred-env.sh
```
# 设置JDK 路径请根据具体自己配置的路径修改
export JAVA_HOME=/opt/tools/jdk1.8.0_181
```

### 2.4.5. core-site.xml [重要]
```
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<configuration>
     <property>
       <name>fs.defaultFS</name>
       <value>hdfs://henghe-030:8020</value>
       <description></description>
     </property>
   
     <property>
       <name>io.file.buffer.size</name>
       <value>131072</value>
       <description></description>
     </property>
   
   <property>
     <name>hadoop.security.authorization</name>
     <value>true</value>
     <description>是否开启hadoop的安全认证</description>
   </property>
   
   <property>
     <name>hadoop.security.authentication</name>
     <value>kerberos</value>
     <description>使用kerberos作为hadoop的安全认证方案</description>
   </property>
   <property>
     <name>hadoop.rpc.protection</name>
     <value>authentication</value>
     <description>authentication : authentication only (default); integrity : integrity check in addition to authentication; privacy : data encryption in addition to integrity</description>
   </property>
   
   <property>
     <name>hadoop.security.auth_to_local</name>
     <value>
        RULE:[2:$1@$0](hdfs@.*HENGHE.COM)s/.*/hdfs/
        RULE:[2:$1@$0](yarn@.*HENGHE.COM)s/.*/yarn/
        DEFAULT
     </value>
   </property>
   
    <property>
      <name>hadoop.proxyuser.root.hosts</name>
      <value>*</value>
   </property>
   
   <property>
      <name>hadoop.proxyuser.root.groups</name>
      <value>*</value>
   </property>
   
   <property>
      <name>hadoop.proxyuser.hdfs.hosts</name>
      <value>*</value>
   </property>
   
   <property>
      <name>hadoop.proxyuser.hdfs.groups</name>
      <value>*</value>
   </property>
   
   <property>
      <name>hadoop.proxyuser.yarn.hosts</name>
      <value>*</value>
   </property>
   
   <property>
      <name>hadoop.proxyuser.yarn.groups</name>
      <value>*</value>
   </property>
    
   <property>
      <name>hadoop.proxyuser.hive.hosts</name>
      <value>*</value>
   </property>
   
   <property>
      <name>hadoop.proxyuser.hive.groups</name>
      <value>*</value>
   </property>
</configuration>
```

### 2.4.6. hdfs-site.xml [重要]
```
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<configuration>


    <property>
        <name>dfs.namenode.hosts</name>
        <value>henghe-030</value>
        <description>List of permitted DataNodes.</description>
    </property>

    <property>
        <name>dfs.block.access.token.enable</name>
        <value>true</value>
        <description>Enable HDFS block access tokens for secure operations</description>
    </property>

    <property>
        <name>dfs.permissions.supergroup</name>
        <value>hadoop</value>
    </property>

    <!-- 存储目录&副本数量相关 -->
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/tools/hadoop-3.1.3/data/hdfs/data</value>
        <final>true</final>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/opt/tools/hadoop-3.1.3/data/namenode</value>
        <final>true</final>
    </property>
     <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>

    <!-- NameNode security config -->
    <property>
        <name>dfs.namenode.kerberos.principal</name>
        <value>hdfs/_HOST@HENGHE.COM</value>
        <description>namenode对应的kerberos账户为 nn/主机名@HENGHE.COM    _HOST会自动转换为主机名</description>
    </property>

    <property>
        <name>dfs.namenode.keytab.file</name>
        <value>/opt/keytab/hdfs.keytab</value>
        <description>因为使用-randkey 创建的用户 密码随机不知道，所以需要用免密登录的keytab文件 指定namenode需要用的keytab文件在哪里</description>
    </property>

    <property>
        <name>dfs.namenode.kerberos.internal.spnego.principal</name>
        <value>hdfs/_HOST@HENGHE.COM</value>
        <description>https 相关（如开启namenodeUI）使用的账户</description>
    </property>


    <!--Secondary NameNode security config -->
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>0.0.0.0:9868</value>
        <description>HTTP web UI address for the Secondary NameNode.</description>
    </property>
    <property>
        <name>dfs.namenode.secondary.https-address</name>
        <value>0.0.0.0:9869</value>
        <description>HTTPS web UI address for the Secondary NameNode.</description>
    </property>

    <property>
        <name>dfs.secondary.namenode.kerberos.principal</name>
        <value>hdfs/_HOST@HENGHE.COM</value>
        <description>secondarynamenode使用的账户</description>
    </property>
    <property>
        <name>dfs.secondary.namenode.keytab.file</name>
        <value>/opt/keytab/hdfs.keytab</value>
        <description>sn对应的keytab文件</description>
    </property>

    <property>
        <name>dfs.secondary.namenode.kerberos.internal.spnego.principal</name>
        <value>hdfs/_HOST@HENGHE.COM</value>
        <description>sn需要开启http页面用到的账户</description>
    </property>


    <!-- DataNode security config -->
    <property>
        <name>dfs.datanode.data.dir.perm</name>
        <value>700</value>
    </property>
    <property>
        <name>dfs.datanode.address</name>
        <value>0.0.0.0:1004</value>
        <description>[重要]安全数据节点必须使用特权端口，以确保服务器安全启动。这意味着服务器必须通过jsvc启动。 或者，如果使用SASL对数据传输协议进行身份验证，则必须将其设置为非特权端口. (See dfs.data.transfer.protection.)</description>
    </property>
    <property>
        <name>dfs.datanode.http.address</name>
        <value>0.0.0.0:1006</value>
        <description>[重要]安全数据节点必须使用特权端口，以确保服务器安全启动。这意味着服务器必须通过jsvc启动。</description>
    </property>
    <property>
        <name>dfs.datanode.https.address</name>
        <value>0.0.0.0:9865</value>
        <description>HTTPS web UI address for the Data Node.</description>
    </property>
    <property>
        <name>dfs.encrypt.data.transfer</name>
        <value>true</value>
        <description>数据传输协议激活数据加密</description>
    </property>
    <property>
        <name>dfs.datanode.kerberos.principal</name>
        <value>hdfs/_HOST@HENGHE.COM</value>
        <description>datanode用到的账户</description>
    </property>
    <property>
        <name>dfs.datanode.keytab.file</name>
        <value>/opt/keytab/hdfs.keytab</value>
        <description>datanode用到的keytab文件路径</description>
    </property>

    
    <!-- WebHDFS security config -->
    <property>
        <name>dfs.web.authentication.kerberos.principal</name>
        <value>hdfs/_HOST@HENGHE.COM</value>
        <description>web hdfs 使用的账户</description>
    </property>
    <property>
        <name>dfs.web.authentication.kerberos.keytab</name>
        <value>/opt/keytab/hdfs.keytab</value>
        <description>对应的keytab文件</description>
    </property>
    
   
</configuration>

```

- 注意这个参数如果使用JSVC 是不允许加的.
 ```
 <property>
        <name>dfs.data.transfer.protection</name>
        <value>integrity</value>
        <description>authentication : authentication only; integrity : integrity check in addition to authentication; privacy : data encryption in addition to integrity This property is unspecified by default. Setting this property enables SASL for authentication of data transfer protocol. If this is enabled, then dfs.datanode.address must use a non-privileged port, dfs.http.policy must be set to HTTPS_ONLY and the HDFS_DATANODE_SECURE_USER environment variable must be undefined when starting the DataNode process.</description>
    </property>
```

### 2.4.7. 设置JSVC

JSVC是Java应用的辅助程序，其中包含了一定数械的库和应用程序，能够使一些Java程序使用root权限进行一些需要权限的操作，并进行用户之间的切换。

#### 2.4.7.1 下载地址

官方地址: https://commons.apache.org/proper/commons-daemon/download_daemon.cgi
百度云盘: 链接: https://pan.baidu.com/s/1O1dS7SmayzaQaiPggi3CuA 密码: 5nto

#### 2.4.7.2 编译 [必须]
```
wget https://downloads.apache.org//commons/daemon/source/commons-daemon-1.2.4-src.tar.gz
tar -xzvf commons-daemon-1.2.4-src.tar.gz
cd commons-daemon-1.2.4-src/src/native/unix/
./configure --with-java=/opt/tools/jdk1.8.0_181

# 编译
make

# 编译之后目录下会生成一个jsvc的指令
# 验证
./jsvc --help
```

如果make指令找不到的话 , 执行下面的执行,安装插件.然后再重试…
```
yum group install "Development Tools" -y
```

#### 2.4.7.3 安装

将编译后的`jsvc`指令 复制到 ${HADOOP_HOME}/libexec 目录下
```
cp jsvc /opt/tools/hadoop-3.1.3/libexec/
```

首先确认`${HADOOP_HOME}/share/hadoop/hdfs/lib`目录下没有jar包:` commons-daemon-*.jar`, 如果有,删除!!!

将编译后或者下载的文件找到`commons-daemon-1.2.4.jar`放到`${HADOOP_HOME}/share/hadoop/hdfs/lib`目录下

#### 2.4.7.4 修改hadoop-env.sh文件
```
vi ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

#新增/修改参数
export HDFS_DATANODE_SECURE_USER=hdfs
export JSVC_HOME=/opt/tools/hadoop-3.1.3/libexec
```

### 2.4.8. 配置ssl-server.xml和ssl-client.xml [开启https设置,否则忽略]

#### 2.4.8.1.创建HTTPS证书

- 在mster01上执行指令, 创建目录
```
# 创建目录

[hdfs@master01 hadoop]# mkdir -p /opt/security/kerberos_https
[hdfs@master01 hadoop]# cd /opt/security/kerberos_https
```

执行创建指令, 输入密码
```
openssl req -new -x509 -keyout bd_ca_key -out bd_ca_cert -days 9999 -subj '/C=CN/ST=beijing/L=beijing/O=test/OU=test/CN=test'
```

```
[hdfs@master01 kerberos_https]# openssl req -new -x509 -keyout bd_ca_key -out bd_ca_cert -days 9999 -subj '/C=CN/ST=beijing/L=beijing/O=test/OU=test/CN=test'
Generating a 2048 bit RSA private key
.....................................................................................................+++
.+++
writing new private key to 'bd_ca_key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
[hdfs@master01 kerberos_https]#
[hdfs@master01 kerberos_https]#

# （输入密码和确认密码是123456，此命令成功后输出bd_ca_key和bd_ca_cert两个文件）

[hdfs@master01 kerberos_https]# ll
总用量 8
-rw-r--r-- 1 root root 1294 3月  27 19:36 bd_ca_cert
-rw-r--r-- 1 root root 1834 3月  27 19:36 bd_ca_key
[hdfs@master01 kerberos_https]#
```

- 将得到的两个文件复制到其他机器上面.
```
scp -r /opt/security/kerberos_https root@xxx : /opt/security/
```

- 在每个节点上都依次执行以下命令:
```
 cd /opt/security/kerberos_https

# 所有需要输入密码的地方全部输入123456（方便起见，如果你对密码有要求请自行修改）

# 1  输入密码和确认密码：123456，此命令成功后输出keystore文件
keytool -keystore keystore -alias localhost -validity 9999 -genkey -keyalg RSA -keysize 2048 -dname "CN=test, OU=test, O=test, L=beijing, ST=beijing, C=CN"

# 2 输入密码和确认密码：123456，提示是否信任证书：输入yes，此命令成功后输出truststore文件
keytool -keystore truststore -alias CARoot -import -file bd_ca_cert

# 3 输入密码和确认密码：123456，此命令成功后输出cert文件
keytool -certreq -alias localhost -keystore keystore -file cert

# 4 此命令成功后输出cert_signed文件
openssl x509 -req -CA bd_ca_cert -CAkey bd_ca_key -in cert -out cert_signed -days 9999 -CAcreateserial -passin pass:123456

# 5 输入密码和确认密码：123456，是否信任证书，输入yes，此命令成功后更新keystore文件
keytool -keystore keystore -alias CARoot -import -file bd_ca_cert

# 6 输入密码和确认密码：123456
keytool -keystore keystore -alias localhost -import -file cert_signed


最终得到:
 -rw-r--r-- 1 root root 1294 3月  27 19:36 bd_ca_cert
 -rw-r--r-- 1 root root   17 3月  27 19:43 bd_ca_cert.srl
 -rw-r--r-- 1 root root 1834 3月  27 19:36 bd_ca_key
 -rw-r--r-- 1 root root 1081 3月  27 19:43 cert
 -rw-r--r-- 1 root root 1176 3月  27 19:43 cert_signed
 -rw-r--r-- 1 root root 4055 3月  27 19:43 keystore
 -rw-r--r-- 1 root root  978 3月  27 19:42 truststore
```

#### 2.4.8.2. ssl-server.xm在`${HADOOP_HOME}/etc/hadoop`目录构建`ssl-server.xml`文件

> 注意 : 路径和密码别忘了改…
```
<configuration>

    <property>
        <name>ssl.server.truststore.location</name>
        <value>/opt/security/kerberos_https/truststore</value>
        <description>Truststore to be used by NN and DN. Must be specified.</description>
    </property>

    <property>
        <name>ssl.server.truststore.password</name>
        <value>123456</value>
        <description>Optional. Default value is "". </description>
    </property>

    <property>
        <name>ssl.server.truststore.type</name>
        <value>jks</value>
        <description>Optional. The keystore file format, default value is "jks".</description>
    </property>

    <property>
        <name>ssl.server.truststore.reload.interval</name>
        <value>10000</value>
        <description>Truststore reload check interval, in milliseconds. Default value is 10000 (10 seconds). </description>
    </property>

    <property>
        <name>ssl.server.keystore.location</name>
        <value>/opt/security/kerberos_https/keystore</value>
        <description>Keystore to be used by NN and DN. Must be specified.</description>
    </property>

    <property>
        <name>ssl.server.keystore.password</name>
        <value>123456</value>
        <description>Must be specified.</description>
    </property>

    <property>
        <name>ssl.server.keystore.keypassword</name>
        <value>123456</value>
        <description>Must be specified.</description>
    </property>

    <property>
        <name>ssl.server.keystore.type</name>
        <value>jks</value>
        <description>Optional. The keystore file format, default value is "jks".</description>
    </property>

    <property>
        <name>ssl.server.exclude.cipher.list</name>
        <value>TLS_ECDHE_RSA_WITH_RC4_128_SHA,SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA,
        SSL_RSA_WITH_DES_CBC_SHA,SSL_DHE_RSA_WITH_DES_CBC_SHA,
        SSL_RSA_EXPORT_WITH_RC4_40_MD5,SSL_RSA_EXPORT_WITH_DES40_CBC_SHA,
        SSL_RSA_WITH_RC4_128_MD5</value>
        <description>Optional. The weak security cipher suites that you want excludedfrom SSL communication.</description>
    </property>
   
</configuration>
```

#### 2.4.8.3. ssl-client.xml

在`${HADOOP_HOME}/etc/hadoop`目录构建`ssl-client.xml`文件

> 注意 : 路径和密码别忘了改…
```
<configuration>

    <property>
        <name>ssl.client.truststore.location</name>
        <value>/opt/security/kerberos_https/truststore</value>
        <description>Truststore to be used by clients like distcp. Must be specified.  </description>
    </property>

    <property>
        <name>ssl.client.truststore.password</name>
        <value>123456</value>
        <description>Optional. Default value is "". </description>
    </property>

    <property>
        <name>ssl.client.truststore.type</name>
        <value>jks</value>
        <description>Optional. The keystore file format, default value is "jks".</description>
    </property>

    <property>
        <name>ssl.client.truststore.reload.interval</name>
        <value>10000</value>
        <description>Truststore reload check interval, in milliseconds. Default value is 10000 (10 seconds). </description>
    </property>

    <property>
        <name>ssl.client.keystore.location</name>
        <value>/opt/security/kerberos_https/keystore</value>
        <description>Keystore to be used by clients like distcp. Must be   specified.   </description>
    </property>

    <property>
        <name>ssl.client.keystore.password</name>
        <value>123456</value>
        <description>Optional. Default value is "". </description>
    </property>

    <property>
        <name>ssl.client.keystore.keypassword</name>
        <value>123456</value>
        <description>Optional. Default value is "". </description>
    </property>

    <property>
        <name>ssl.client.keystore.type</name>
        <value>jks</value>
        <description>Optional. The keystore file format, default value is "jks". </description>
    </property>
    
</configuration>
```

##### 2.4.8.4. 开启https

修改hdfs-site.xml
```
	   <property>
           <name>dfs.http.policy</name>
           <value>HTTPS_ONLY</value>
           <description>所有开启的web页面均使用https, 细节在ssl server 和client那个配置文件内配置</description>
       </property>
```

### 2.4.9. 配置 workers

将datanode节点所在的host加入到${HADOOP_HOME}/etc/hadoop/workers 里面…
```
[hdfs@master01 hadoop]# vi workers
master01
```

### 2.4.10. 将HDFS相关配置文件复制到其他节点

直接同步配置
```
${HADOOP_HOME}/etc/hadoop
```
比如`core-site.xml`、`hdfs-site.xml`、`hadoop-env.sh`等等…


# 三 .启动HDFS测试

## 3.1. 启动NameNode

1.切换到启动namenode的用户,进行认证
```
[hdfs@master01 keytab]# kinit -kt /opt/keytab/hdfs.keytab hdfs/master01@HENGHE.COM
[hdfs@master01 keytab]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: hdfs/master01@HENGHE.COM

Valid starting       Expires              Service principal
2021-03-27T20:01:39  2021-03-2
```

2.格式化namenode [ 如果是新安装的集群需要格式化… ]

执行`hadoop namenode -format`

3.启动`namenode`和`secondarynamenode`
```
cd ${HADOOP_HOME}/sbin

sh hadoop-daemon.sh start namenode

sh hadoop-daemon.sh start secondarynamenode
```

4.访问Web UI
```
http://master01:9870
```

- 如果是https的话, 默认端口是9871
```
https://master01:9871
```

- 开启https如果Chrome 浏览器会做拦截. 提示: Chrome不允许您访问某些网站并引发证书/ HSTS错误。

解决方式 :
- 只需要在Chrome 浏览器窗口, 直键盘输入 thisisunsafe 告诉Chrome跳过证书验证。
(不需要考虑光标在哪,只要在Chrome 浏览器窗口直接敲就行 )



- 如果无法访问web页面, 可以通过以下方式查看端口.
```
yum install -y net-tools

netstat -anp|grep 21400[namenode的进程id]

# 如果没有netstat安装指令, 需要安装 net-tools
[hdfs@master01 sbin]# yum install -y net-tools


# 查看 web ui的端口为  9870/9871
[hdfs@master01 sbin]# netstat -anp|grep 21400
tcp        0      0 0.0.0.0:9871           0.0.0.0:*               LISTEN      21400/java
tcp        0      0 192.168.xx.xx:8020     0.0.0.0:*               LISTEN      21400/java
unix  2      [ ]         STREAM     CONNECTED     912276   21400/java
unix  2      [ ]         STREAM     CONNECTED     912278   21400/java
[hdfs@master01 sbin]#
```

## 3.2. 启动DataNode

1.切换到启动datanode的用户,进行认证 .
```
[hdfs@master01 keytab]# kinit -kt /opt/keytab/hdfs.keytab hdfs/master01@HENGHE.COM
[hdfs@master01 keytab]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: hdfs/master01@HENGHE.COM

Valid starting       Expires              Service principal
2021-03-27T20:01:39  2021-03-2
```

2.启动datanode
```
cd ${HADOOP_HOME}/sbin


# 如果使用JSVC, 使用该命令启动.
sudo sh start-secure-dns.sh

# 如果开启https使用该方式启动
sh hadoop-daemon.sh start datanode
```

3.访问web UI

http方式访问 : https://192.xx.xx.xx:9870/dfshealth.html#tab-datanode

https方式访问 : https://192.xx.xx.xx:9871/dfshealth.html#tab-datanode


# 四. 遇到的坑

## 4.1. 未开启HTTPS, DataNode启动失败: Cannot start secure DataNode due to incorrect config.

- 报错信息
```
2021-03-30 14:05:13,021 INFO org.apache.hadoop.util.ExitUtil: Exiting with status 1: java.lang.RuntimeException: Cannot start secure DataNode due to incorrect config. See https://cwiki.apache.org/confluence/display/HADOOP/Secure+DataNode for details.
/HADOOP/Secure+DataNode for details.
	at org.apache.hadoop.hdfs.server.datanode.DataNode.checkSecureConfig(DataNode.java:1523)
	at org.apache.hadoop.hdfs.server.datanode.DataNode.startDataNode(DataNode.java:1376)
	at org.apache.hadoop.hdfs.server.datanode.DataNode.<init>(DataNode.java:501)
	at org.apache.hadoop.hdfs.server.datanode.DataNode.makeInstance(DataNode.java:2806)
	at org.apache.hadoop.hdfs.server.datanode.DataNode.instantiateDataNode(DataNode.java:2714)
	at org.apache.hadoop.hdfs.server.datanode.DataNode.createDataNode(DataNode.java:2756)
	at org.apache.hadoop.hdfs.server.datanode.DataNode.secureMain(DataNode.java:2900)
	at org.apache.hadoop.hdfs.server.datanode.DataNode.main(DataNode.java:2924)
```

原因 :

肯定是配置有问题:
- 如果是JSVC方式的话,检查2.4.7. JSVC 配置 .
- 如果是https方式的话,按照 2.4.8 章节检查https配置

## 4.2. DataNode无法连接上NameNode 提示 : GSS initiate failed

- 报错信息
```
2021-03-28 17:57:11,389 WARN SecurityLogger.org.apache.hadoop.ipc.Server: Auth failed for 192.168.100.23:44542:null (GSS initiate failed) with true cause: (GSS initiate failed)
2021-03-28 17:57:14,706 WARN SecurityLogger.org.apache.hadoop.ipc.Server: Auth failed for 192.168.100.23:34648:null (GSS initiate failed) with true cause: (GSS initiate failed)
2021-03-28 17:57:17,640 WARN SecurityLogger.org.apache.hadoop.ipc.Server: Auth failed for 192.168.100.23:40533:null (GSS initiate failed) with true cause: (GSS initiate failed)
2021-03-28 17:57:22,536 WARN SecurityLogger.org.apache.hadoop.ipc.Server: Auth failed for 192.168.100.23:42784:null (GSS initiate failed) with true cause: (GSS initiate failed)
2021-03-28 17:57:27,030 WARN SecurityLogger.org.apache.hadoop.ipc.Server: Auth failed for 192.168.100.23:45400:null (GSS initiate failed) with true cause: (GSS initiate failed)
2021-03-28 17:57:28,303 WARN SecurityLogger.org.apache.hadoop.ipc.Server: Auth failed for 192.168.100.23:43149:null (GSS initiate failed) with true cause: (GSS initiate failed)
```

- 解决方式

JDK没有装JCE组件, JDK需要下载安装JCE组件. 重启服务即可…

参考文章 JDK8 安装 [Java Cryptography Extension（JCE](https://zhangboyi.blog.csdn.net/article/details/115285334)

## 4.3. Hadoop集成kerberos后,报错:AccessControlException

- 报错信息: `AccessControlException: Client cannot authenticate via:[TOKEN, KERBEROS]`
```
[hdfs@master01 ~]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: hdfs/master01@HENGHE.COM

Valid starting       Expires              Service principal
2021-03-28T17:35:19  2021-03-29T17:35:19  krbtgt/HENGHE.COM@HENGHE.COM
[hdfs@master01 ~]#
[hdfs@master01 ~]# hadoop fs -ls /
2021-03-28 20:23:27,667 WARN ipc.Client: Exception encountered while connecting to the server : org.apache.hadoop.security.AccessControlException: Client cannot authenticate via:[TOKEN, KERBEROS]
ls: DestHost:destPort master01:8020 , LocalHost:localPort master01/192.xx.xx:0. Failed on local exception: java.io.IOException: org.apache.hadoop.security.AccessControlException: Client cannot authenticate via:[TOKEN, KERBEROS]
```

- 解决方式:
修改 Kerboeros配置文件 /etc/krb5.conf , 注释掉 : default_ccache_name 属性 .

然后执行kdestroy,重新kinit .

参考文章 :[Hadoop集成kerberos后,报错:AccessControlException: Client cannot authenticate via:[TOKEN, KERBEROS]](https://zhangboyi.blog.csdn.net/article/details/115287040)

参考：
- http://www.senlt.cn/article/149237253.html
- https://cloud.tencent.com/developer/article/2089176
- https://zhangboyi.blog.csdn.net/article/details/115298985?spm=1001.2014.3001.5502
