# 一 .前言

本文主要记录YARN如何开启Kerberos. Kerberos如何安装请参考文章 Kerberos 安装&使用

## 1.1. 环境说明

| 组件 | 版本 |
|------|------|
| 操作系统 | CentOS 7.6 |
| JDK	JDK | 1.8.0_161+ [低版本需要安装JCE!!!] |
| Hadoop | 3.1.3 |
| Kerberos | krb5 , 安装参考Kerberos 安装&使用 |

## 1.2. 服务规划

规划需要启动YARN所需要的用户&凭证信息. (当然也可以用一个.)

为了节约时间,我就统一使用root用户进行安装.

因为就一个master01节点, 所以凭证信息统一使用`yarn/master01@HENGHE.COM`

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

## 1.4. 安装YARN环境

YARN环境需要提前安装, 安装文档参考 : [ HDFS 3.1.x ] 开启Kerberos配置&使用

## 1.5. 配置环境变量

修改/etc/profile文件.

- 新增内容:
```
export JAVA_HOME=/opt/java/jdk1.8
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

# 二 .安装YARN

至此，Kerberos 和 HDFS 已经安装完成，现在需要配置Yarn集群.

## 2.1. 添加用户

在各个物理机上创建YARN相关的用户.

[因为我直接使用yarn用户安装, 所以下面的步骤就直接创建yarn用户就可以了]
```
groupadd hadoop;
useradd hdfs -g hadoop -p hdfs;
useradd hive -g hadoop -p hive;
useradd yarn -g hadoop -p yarn;
useradd mapred -g hadoop -p mapred
```

- 记得设置文件的权限,并且切换用户为yarn进行安装

## 2.2. 配置YARN相关的Kerberos账户

`Hadoop`需要`Kerberos`来进行认证，以启动服务来说，在后面配置`hadoop`的时候我们会给对应服务指定一个Kerberos的账户，比如`ResourceManager`运行在master01机器上，我们可能将 `ResourceManager`指定给了`rm/master01@HENGHE.COM`这个账户， 那么 想要启动`ResourceManager`就必须认证这个账户才可以。

### 2.2.1. 创建keytab存放目录

在每个节点执行
```
# mkdir -p /opt/keytab
```

### 2.2.2. 配置master01上面运行的服务对应的Kerberos账户

在每台机器上构建kerberos用户&导出凭证
```
# 进入kadmin
kadmin.local

# 查看用户
listprincs

# 创建用户
addprinc -randkey yarn/master01@HENGHE.COM

# 导出keytab文件
ktadd -k /opt/keytab/yarn.keytab yarn/master01@HENGHE.COM
```

### 2.2.3. keytab权限设置

需要注意keytab 的权限, 因为我是使用root用户安装,所以不做操作.

- 参考指令
在master01上将刚刚得到的 keytab文件全部设置:
```
chown yarn:hadoop yarn.keytab
```
以及
```
chmod 400 yarn.keytab
```

### 2.2.4. 编译源码构建Linux-Container-executor

`Kerberos`需要使用基于`cgroup`工作的一个名为`Linux-container-executer`的容器来运行YARN任务，这个容器需要我们自己编译源码来构建出来如果编译不出来可以在网络上找找, 编译步骤就不详细说明了.

- 要安装 protobuf-2.5.0 (截止到hadoop的3.2.1版本,必须使用protobuf-2.5.0版本,否则报错.)
```
./configure
make
make install
```

- 编译 containerexecutor
```
cd $HADOOP_HOME/src/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoopyarn-server-nodemanager

mvn package -Pdist,native -DskipTests -Dtar -Dcontainerexecutor.conf.dir=/opt/yarn-executor
```

/opt/tools/hadoop-3.1.3/etc

记得编译好之后,将container-executor 同步到各个节点的bin目录下.

### 2.2.5. 设置 hadoop 需要使用的各个目录的权限

```
export HADOOP_HOME=/opt/tools/hadoop-3.1.3
export NODEMANAGER_LOCAL_DIR=$HADOOP_HOME/data/local-dirs
export NODEMANAGER_LOG_DIR=$HADOOP_HOME/data/logs/userlogs
export MR_HISTORY=$HADOOP_HOME/data/mr-data


 




chown root:hadoop $HADOOP_HOME

chown yarn:hadoop $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh
chown yarn:hadoop $HADOOP_HOME/sbin/start-yarn.sh
chown yarn:hadoop $HADOOP_HOME/sbin/stop-yarn.sh
chown yarn:hadoop $HADOOP_HOME/sbin/yarn-daemon.sh
chown yarn:hadoop $HADOOP_HOME/sbin/yarn-daemons.sh
chown yarn:hadoop $HADOOP_HOME/bin/mapred*
chown yarn:hadoop $HADOOP_HOME/bin/yarn*
chown yarn:hadoop $HADOOP_HOME/etc/hadoop/mapred-*
chown yarn:hadoop $HADOOP_HOME/etc/hadoop/yarn-*
chmod 755 -R $HADOOP_HOME/etc/hadoop/*
chown root:hadoop $HADOOP_HOME/etc
chown root:hadoop $HADOOP_HOME/etc/hadoop
chown root:hadoop $HADOOP_HOME/etc/hadoop/container-executor.cfg
chown root:hadoop $HADOOP_HOME/bin/container-executor
chown root:hadoop $HADOOP_HOME/bin/test-container-executor
chmod 6050 $HADOOP_HOME/bin/container-executor
chown 6050 $HADOOP_HOME/bin/test-container-executor


mkdir -p $NODEMANAGER_LOCAL_DIR
mkdir -p $NODEMANAGER_LOG_DIR
mkdir -p $MR_HISTORY


chown -R yarn:hadoop $NODEMANAGER_LOCAL_DIR
chown -R yarn:hadoop $NODEMANAGER_LOG_DIR
chmod 770 $NODEMANAGER_LOCAL_DIR
chmod 770 $NODEMANAGER_LOG_DIR
chown -R yarn:hadoop $MR_HISTORY
chmod 770 $MR_HISTORY

mkdir $HADOOP_HOME/logs
chmod 775 $HADOOP_HOME/logs

mkdir  $HADOOP_HOME/data/timeline/
chown yarn:hadoop timeline/

```

## 2.3. 配置hadoop的 lib/native(本地运行库)

Hadoop是使用Java语言开发的，但是有一些需求和操作并不适合使用java，所以就引入了本地库（Native Libraries）的概念，通过本地库，Hadoop可以更加高效地执行某一些操作。

- 存放目录:
```
$HADOOP_HOME/lib/native
```
具体怎么搞native 网上有现成的找找. 不做具体赘述.

## 2.4. 设置 YARN 的配置文件

### 2.4.1. `[start/stop]-yarn.sh`

> 非root账户操作,忽略本小结

启动的时候,如果想使用root账户用sbin/[start/stop]-yarn.sh 脚本启动. 需要做一些配置

修改 sbin/[start/stop]-yarn.sh 在脚本的开头加入指令:
```
YARN_RESOURCEMANAGER_USER=root
HADOOP_SECURE_DN_USER=root
YARN_NODEMANAGER_USER=root
```

### 2.4.2. hadoop-env.sh
```
# 设置JDK 路径请根据具体自己配置的路径修改
export JAVA_HOME=/usr/local/jdk1.8.0_221
```

### 2.4.3. yarn-env.sh
```
# 设置JDK 路径请根据具体自己配置的路径修改
export JAVA_HOME=/usr/local/jdk1.8.0_221
```

### 2.4.4. mapred-env.sh
```
# 设置JDK 路径请根据具体自己配置的路径修改
export JAVA_HOME=/usr/local/jdk1.8.0_221
```

### 2.4.5. yarn-site.xml [重要]
```
<?xml version="1.0"?>
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
        <name>hadoop.http.authentication.type</name>
        <value>kerberos</value>
    </property>

    <property>
        <name>hadoop.http.filter.initializers</name>
        <value>org.apache.hadoop.security.AuthenticationFilterInitializer</value>
    </property>

    <property>
        <name>yarn.resourcemanager.webapp.delegation-token-auth-filter.enabled</name>
        <value>false</value>
        <description>标记以启用使用RM身份验证筛选器覆盖默认kerberos身份验证筛选器以允许使用委派令牌进行身份验证（如果缺少令牌，则回退到kerberos）。仅适用于http身份验证类型为kerberos的情况。</description>
    </property>


    <property>
        <name>yarn.acl.enable</name>
        <value>true</value>
        <description>Enable ACLs? Defaults to false.</description>
    </property>
    <property>
        <name>yarn.admin.acl</name>
        <value>yarn hadoop</value>
        <description>ACL to set admins on the cluster. ACLs are of for comma-separatedusersspacecomma-separated-groups. Defaults to special value of * which means anyone.Special value of just space means no one has access.</description>
    </property>

    <property>
        <name>hadoop.http.authentication.kerberos.principal</name>
        <value>HTTP/_HOST@HENGHE.COM</value>
    </property>

    <property>
        <name>hadoop.http.authentication.kerberos.keytab</name>
        <value>/opt/keytab/HTTP.keytab</value>
    </property>

    <!-- ResourceManager security configs -->

    <property>
        <name>yarn.resourcemanager.principal</name>
        <value>yarn/_HOST@HENGHE.COM</value>
    </property>

    <property>
        <name>yarn.resourcemanager.keytab</name>
        <value>/opt/keytab/yarn.keytab</value>
    </property>

    <!-- NodeManager security configs -->

    <property>
        <name>yarn.nodemanager.principal</name>
        <value>yarn/_HOST@HENGHE.COM</value>
    </property>

    <property>
        <name>yarn.nodemanager.keytab</name>
        <value>/opt/keytab/yarn.keytab</value>
    </property>

    <property>
        <name>yarn.nodemanager.container-executor.class</name>
        <value>org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor</value>
    </property>

    <property>
        <name>yarn.nodemanager.linux-container-executor.group</name>
        <value>hadoop</value>
        <description>这里记得改啊...</description>
    </property>

    <property>
        <name>yarn.nodemanager.linux-container-executor.path</name>
        <value>/opt/tools/hadoop-3.1.3/bin/container-executor</value>
    </property>

    <!-- webapp webapp configs -->
    <property>
        <name>yarn.resourcemanager.webapp.spnego-principal</name>
        <value>HTTP/_HOST@HENGHE.COM</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.spnego-keytab-file</name>
        <value>/opt/keytab/HTTP.keytab</value>
    </property>


    <!-- TimeLine security configs -->
    <property>
        <name>yarn.timeline-service.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.timeline-service.hostname</name>
        <value>henghe-030</value>
    </property>
    <property>
        <name>yarn.timeline-service.generic-application-history.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.timeline-service.leveldb-timeline-store.path</name>
        <value>/opt/tools/hadoop-3.1.3/data/timeline</value>
    </property>
        <property>
        <name>yarn.timeline-service.principal</name>
        <value>yarn/_HOST@HENGHE.COM</value>
    </property>
    <property>
        <name>yarn.timeline-service.keytab</name>
        <value>/opt/keytab/yarn.keytab</value>
    </property>

    <property>
        <name>yarn.timeline-service.http-authentication.type</name>
        <value>kerberos</value>
    </property>

    <property>
        <name>yarn.timeline-service.http-authentication.kerberos.principal</name>
        <value>HTTP/_HOST@HENGHE.COM</value>
    </property>

    <property>
        <name>yarn.timeline-service.http-authentication.kerberos.keytab</name>
       <value>/opt/keytab/HTTP.keytab</value>
    </property>

    <!-- Site specific YARN configuration properties -->  
    <property>
        <name>yarn.log.server.url</name>
        <value>https://henghe-030:19890/jobhistory/logs</value>
        <description></description>
    </property>


    <property>
        <name>yarn.acl.enable</name>
        <value>true</value>
        <description>Enable ACLs? Defaults to false.</description>
    </property>


    <property>
        <name>yarn.admin.acl</name>
        <value>root,hdfs,yarn,http hadoop</value>
        <description>ACL to set admins on the cluster. ACLs are of for comma-separated-usersspacecomma-separated-groups. Defaults to special value of * which means anyone. Special value of just space means no one has access.</description>
    </property>


    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
        <description>Configuration to enable or disable log aggregation</description>
    </property>

    <property>
        <name>yarn.nodemanager.remote-app-log-dir</name>
        <value>/tmp/logs</value>
        <description>Configuration to enable or disable log aggregation</description>
    </property>

    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>henghe-030</value>
        <description></description>
    </property>

    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
        <description></description>
    </property>


    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        <description>Shuffle service that needs to be set for Map Reduce applications.</description>
    </property>

    <property>
        <name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>

    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>1048576</value>
    </property>

    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>16</value>
    </property>

    <property>
        <name>yarn.nodemanager.resource.detect-hardware-capabilities</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.nodemanager.log-container-debug-info.enabled</name>
        <value>true</value>
    </property>

    <property>
        <name>yarn.nodemanager.container-executor.os.sched.priority.adjustment</name>
        <value>6</value>
    </property>

    <property>
        <name>yarn.nodemanager.log-dirs</name>
        <value>/opt/tools/hadoop-3.1.3/data/logs/userlogs</value>
    </property>

    <property>
        <name> yarn.nodemanager.local-dirs</name>
        <value>/opt/tools/hadoop-3.1.3/data/local-dirs</value>
    </property>

    <property>
        <name>yarn.nodemanager.log.retain-seconds</name>
        <value>10800</value>
        <description>Default time (in seconds) to retain log files on the NodeManager Only applicable if log-aggregation is disabled.</description>
    </property>

   
</configuration>

```
- 如何http页面要开启 kerberos的话,增加以下配置

通过`hadoop.http.authentication.type`控制是否开启`kerberos`
```
    <!-- webapp webapp configs -->

    <property>
        <name>hadoop.http.authentication.type</name>
        <value>kerberos</value>
        <description>Defines authentication used for Oozie HTTP endpoint. Supported values are: simple | kerberos | #AUTHENTICATION_HANDLER_CLASSNAME#</description>
    </property>

    <property>
        <name>hadoop.http.filter.initializers</name>
        <value>org.apache.hadoop.security.AuthenticationFilterInitializer</value>
    </property>

    <property>
        <name>yarn.resourcemanager.webapp.delegation-token-auth-filter.enabled</name>
        <value>false</value>
        <description>标记以启用使用RM身份验证筛选器覆盖默认kerberos身份验证筛选器以允许使用委派令牌进行身份验证（如果缺少令牌，则回退到kerberos）。仅适用于http身份验证类型为kerberos的情况。</description>
    </property>

    <property>
        <name>hadoop.http.authentication.kerberos.principal</name>
        <value>HTTP/_HOST@HENGHE.COM</value>
    </property>

    <property>
        <name>hadoop.http.authentication.kerberos.keytab</name>
        <value>/opt/keytab/HTTP.keytab</value>
    </property>

    <property>
        <name>yarn.resourcemanager.webapp.spnego-principal</name>
        <value>HTTP/_HOST@HENGHE.COM</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.spnego-keytab-file</name>
        <value>/opt/keytab/HTTP.keytab</value>
    </property>

```

- 配置 TimeLine

通过`yarn.timeline-service.http-authentication.type`控制是否开启`kerberos`.
```
<!-- TimeLine security configs -->
    <property>
        <name>yarn.timeline-service.http-authentication.type</name>
        <value>kerberos</value>
        <description>Defines authentication used for the timeline server HTTP endpoint. Supported values are: simple | kerberos | #AUTHENTICATION_HANDLER_CLASSNAME#</description>
    </property>

    <property>
        <name>yarn.timeline-service.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.timeline-service.hostname</name>
        <value>henghe-030</value>
    </property>
    <property>
        <name>yarn.timeline-service.generic-application-history.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.timeline-service.leveldb-timeline-store.path</name>
        <value>/opt/tools/hadoop-3.1.3/data/timeline</value>
    </property>
        <property>
        <name>yarn.timeline-service.principal</name>
        <value>yarn/_HOST@HENGHE.COM</value>
    </property>
    <property>
        <name>yarn.timeline-service.keytab</name>
        <value>/opt/keytab/yarn.keytab</value>
    </property>
    <property>
        <name>yarn.timeline-service.http-authentication.kerberos.principal</name>
        <value>HTTP/_HOST@HENGHE.COM</value>
    </property>

    <property>
        <name>yarn.timeline-service.http-authentication.kerberos.keytab</name>
       <value>/opt/keytab/HTTP.keytab</value>
    </property>
```

### 2.4.6. mapred-site.xml
```
<?xml version="1.0"?>
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

<!-- Put site-specific property overrides in this file. -->

<configuration>

    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        <description></description>
    </property>

    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>henghe-030:10020</value>
        <description></description>
    </property>


    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>henghe-030:19888</value>
        <description></description>
    </property>


    <property>
        <name>mapreduce.jobhistory.intermediate-done-dir</name>
        <value>/opt/tools/hadoop-3.1.3/data/mr-data/mr-history/tmp</value>
        <description></description>
    </property>


    <property>
        <name>mapreduce.jobhistory.done-dir</name>
        <value>/opt/tools/hadoop-3.1.3/data/mr-data/mr-history/done</value>
        <description></description>
    </property>

    <property>
        <name>mapreduce.jobhistory.keytab</name>
        <value>/opt/keytab/yarn.keytab</value>
    </property>

    <property>
        <name>mapreduce.jobhistory.principal</name>
        <value>yarn/_HOST@HENGHE.COM</value>
    </property>

    <property>
        <name>mapreduce.jobhistory.webapp.spnego-principal</name>
        <value>yarn/_HOST@HENGHE.COM</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.webapp.spnego-keytab-file</name>
        <value>/opt/keytab/yarn.keytab</value>
    </property>
</configuration>

```

### 2.4.7. 创建HTTPS证书 [如果已经创建过,请忽略!!!]

- 在mster01上执行指令, 创建目录 [如果已经创建过,请忽略!!!]
```
# 创建目录

[yarn@master01 hadoop]# mkdir -p /opt/security/kerberos_https
[yarn@master01 hadoop]# cd /opt/security/kerberos_https
```

- 执行创建指令, 输入密码
```
openssl req -new -x509 -keyout bd_ca_key -out bd_ca_cert -days 9999 -subj '/C=CN/ST=beijing/L=beijing/O=test/OU=test/CN=test'
```

```
[yarn@master01 kerberos_https]# openssl req -new -x509 -keyout bd_ca_key -out bd_ca_cert -days 9999 -subj '/C=CN/ST=beijing/L=beijing/O=test/OU=test/CN=test'
Generating a 2048 bit RSA private key
.....................................................................................................+++
.+++
writing new private key to 'bd_ca_key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
[yarn@master01 kerberos_https]#
[yarn@master01 kerberos_https]#

# （输入密码和确认密码是123456，此命令成功后输出bd_ca_key和bd_ca_cert两个文件）

[yarn@master01 kerberos_https]# ll
总用量 8
-rw-r--r-- 1 root root 1294 3月  27 19:36 bd_ca_cert
-rw-r--r-- 1 root root 1834 3月  27 19:36 bd_ca_key
[yarn@master01 kerberos_https]#

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

### 2.4.8. 配置ssl-server.xml和ssl-client.xml [如果已经创建过,请忽略!!!]

#### 2.4.8.1. ssl-server.xml

在`${HADOOP_HOME}/etc/hadoop`目录构建`ssl-server.xml`文件

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

#### 2.4.8.1. ssl-client.xml

在`${HADOOP_HOME}/etc/hadoop`目录构建`ssl-client.xml`文件

注意 : 路径和密码别忘了改…
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

### 2.4.9. 配置 workers

将datanode节点所在的host加入到${HADOOP_HOME}/etc/hadoop/workers 里面…
```
[yarn@master01 hadoop]# vi workers
master01
```

### 2.4.10.配置 container-executor.cfg

以root账户编辑
```
# 这个组看情况是否需要更改
yarn.nodemanager.linux-container-executor.group=hadoop
#configured value of yarn.nodemanager.linux-container-executor.group
banned.users=bin
#comma separated list of users who can not run applications
min.user.id=100
#Prevent other super-users
allowed.system.users=root,yarn,hdfs,mapred,hive,dev
##comma separated list of system users who CAN run applications
```

- [重要] 设置container-executor 权限

container-executor 二进制的`owner`必须是`root`，属组必须与`NM`属组相同 ，同时，它的权限必须设置成为`6050`，以赋予它 setuid 的权限，来实现使用不同的用户来启动 container。

另外要注意的是`yarn.nodemanager.linux-container-executor.group`中指定的分组要和提交`application`的用户分组要分开. 否则有安全问题.
```

chown root:hadoop ${HADOOP_HOME}/bin/container-executor 

chmod 6050 ${HADOOP_HOME}/bin/container-executor 


# 目录权限必须为root, 否则报错..
chown root:hadoop ${HADOOP_HOME}/etc/hadoop
chown root:hadoop ${HADOOP_HOME}/etc
chown root:hadoop ${HADOOP_HOME}
```

- [重要] 设置 container-executor.cfg 权限

`container-executor.cfg`二进制的`owner`必须是`root`，属组必须与 NM 属组相同 (hadoop)，同时，它的权限必须设置成为`0400`， 以保证它是只读不可写的
```
chown root:hadoop ${HADOOP_HOME}/etc/hadoop/container-executor.cfg
chmod 0400 ${HADOOP_HOME}/etc/hadoop/container-executor.cfg
```

### 2.4.11. 将YARN相关配置文件复制到其他节点

直接同步文件夹即可 … `${HADOOP_HOME}/etc/hadoop`

# 三 .启动YARN测试

## 3.1. 启动ResourceManager

1.切换到启动resourcemanager的用户,进行认证
```
[yarn@master01 keytab]# kinit -kt /opt/keytab/yarn.keytab yarn/master01@HENGHE.COM
[yarn@master01 keytab]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: yarn/master01@HENGHE.COM

Valid starting       Expires              Service principal
2021-03-27T20:01:39  2021-03-2
```

2.启动resourcemanager
```
cd ${HADOOP_HOME}/sbin

sh yarn-daemon.sh start resourcemanager
```

3.访问Web UI

- http 地址 : https://master01:8088
- https 地址 : https://master01:8090

- Chrome 浏览器,默认会做拦截. 提示: Chrome不允许您访问某些网站并引发证书/ HSTS错误。

解决方式: 只需要在Chrome 浏览器窗口, 直键盘输入 thisisunsafe 告诉Chrome跳过证书验证。

(不需要考虑光标在哪,只要在Chrome 浏览器窗口直接敲就行 )

- 如果无法访问web页面, 可以通过以下方式查看端口.
```
yum install -y net-tools

netstat -anp|grep 16093[ResourceManager的进程id]

# 如果没有netstat安装指令, 需要安装 net-tools
[yarn@master01 sbin]# yum install -y net-tools


# 查看 web ui的端口为  8090
[yarn@master01 sbin]# netstat -anp|grep 16093
tcp        0      0 192.168.xx.xx:8090     0.0.0.0:*               LISTEN      16093/java
tcp        0      0 192.168.xx.xx:8030     0.0.0.0:*               LISTEN      16093/java
tcp        0      0 192.168.xx.xx:8031     0.0.0.0:*               LISTEN      16093/java
tcp        0      0 192.168.xx.xx:8032     0.0.0.0:*               LISTEN      16093/java
tcp        0      0 192.168.xx.xx:8033     0.0.0.0:*               LISTEN      16093/java
unix  2      [ ]         STREAM     CONNECTED     1057830  16093/java
unix  2      [ ]         STREAM     CONNECTED     1057836  16093/java
```

## 3.2. 启动NodeManager

1.切换到启动nodemanager的用户,进行认证 .
```
[yarn@master01 keytab]# kinit -kt /opt/keytab/yarn.keytab yarn/master01@HENGHE.COM
[yarn@master01 keytab]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: yarn/master01@HENGHE.COM

Valid starting       Expires              Service principal
2021-03-27T20:01:39  2021-03-2
```

2. 启动nodemanager
```
cd ${HADOOP_HOME}/sbin

sh yarn-daemon.sh start nodemanager
```

3. 访问web UI
```
https://192.168.xx.xx:8090/cluster/nodes
```

## 3.3. 启动HistoryServer

1.切换到启动historyserver的用户,进行认证 .
```
[yarn@master01 keytab]# kinit -kt /opt/keytab/yarn.keytab yarn/master01@HENGHE.COM
[yarn@master01 keytab]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: yarn/master01@HENGHE.COM

Valid starting       Expires              Service principal
2021-03-27T20:01:39  2021-03-2
```

2.启动historyserver
```
cd ${HADOOP_HOME}/sbin

sh mr-jobhistory-daemon.sh start historyserver
```

3.访问web UI

- http 协议 : https://192.168.xx.xx:19888/jobhistory
- https 协议 : https://192.168.xx.xx:19890/jobhistory


## 3.4. 提交FLINK任务

- 因为yarn的container-executor 不允许用root提交任务,所以创建一个yarn用户的keytab令牌,如果有的话就忽略…
```
# 进入kadmin
kadmin.local

# 查看用户
listprincs

# 创建用户
addprinc -randkey yarn/master01@HENGHE.COM

# 导出keytab文件
ktadd -k /opt/keytab/yarn.keytab -norandkey yarn/master01@HENGHE.COM
```

- 启动flink任务
```
# 开启服务端端口 (如果nc指令找不到: yum install -y nc )
 nc -lk 9999

# 启动flink 消费
cd ${FLINK_HOME}
flink run -t yarn-per-job -c org.apache.flink.streaming.examples.socket.SocketWindowWordCount examples/streaming/SocketWindowWordCount.jar --port 9999
```
