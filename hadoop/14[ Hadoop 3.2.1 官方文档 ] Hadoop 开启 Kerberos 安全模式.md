# 一. 介绍

本文档介绍了如何在安全模式下为Hadoop配置身份验证。将Hadoop配置为以安全模式运行时，每个Hadoop服务和每个用户都必须通过Kerberos进行身份验证。

必须正确配置所有服务主机的正向和反向主机查找，以允许服务彼此进行身份验证。可以使用DNS或`etc/hosts`文件配置主机查找。建议在尝试以安全模式配置Hadoop服务之前，具备Kerberos和DNS的相关知识。

Hadoop的安全功能包括身份验证，服务级别授权，Web身份验证和数据机密性。

# 二. 验证

## 2.1.预制用户帐户

启用服务级别身份验证后，固定用户必须先对自己进行身份验证，然后才能与Hadoop服务进行交互。最简单的方法是使用户使用Kerberos kinit命令进行交互式身份验证。如果无法通过kinit进行交互式登录，则可以使用使用Kerberos keytab文件的程序身份验证。

## 2.2.Hadoop守护程序的用户帐户

确保HDFS和YARN守护程序以不同的Unix用户身份运行，例如hdfs和yarn。另外，请确保MapReduce JobHistory服务器以不同的用户身份（例如mapred）运行。

建议让他们共享一个Unix组，例如hadoop。另请参阅“[从用户到组的映射](https://hadoop.apache.org/docs/r3.1.1/hadoop-project-dist/hadoop-common/SecureMode.html#Mapping_from_user_to_group)”以进行组管理。

| User:Group | Daemons |
|------------|---------|
| hdfs:hadoop | NameNode, Secondary NameNode, JournalNode, DataNode |
| yarn:hadoop | ResourceManager, NodeManager |
| mapred:hadoop | MapReduce JobHistory Server |

## 2.3. Hadoop守护程序的Kerberos 凭证

必须为每个Hadoop Service实例配置其Kerberos 凭证 和keytab文件位置。

服务`principals`的一般格式为`ServiceName/_HOST@REALM.TLD`。例如`dn/_HOST@EXAMPLE.COM`。

Hadoop通过允许将服务 principals 的主机名组件指定为_HOST通配符来简化配置文件的部署。每个服务实例将在运行时将_HOST替换为其自己的标准主机名。这使管理员可以在所有节点上部署相同的配置文件集。但是，密钥表文件将有所不同。

### 2.3.1. HDFS

每个NameNode主机上的NameNode密钥表文件应如下所示：
```
$ klist -e -k -t /etc/security/keytab/nn.service.keytab
Keytab name: FILE:/etc/security/keytab/nn.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 nn/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 nn/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 nn/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

该主机上的Secondary NameNode keytab文件应如下所示：
```
$ klist -e -k -t /etc/security/keytab/sn.service.keytab
Keytab name: FILE:/etc/security/keytab/sn.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 sn/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 sn/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 sn/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

每个主机上的DataNode密钥表文件应如下所示：
```
$ klist -e -k -t /etc/security/keytab/dn.service.keytab
Keytab name: FILE:/etc/security/keytab/dn.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 dn/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 dn/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 dn/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

### 2.3.2. YARN

ResourceManager主机上的ResourceManager密钥表文件应如下所示：
```
$ klist -e -k -t /etc/security/keytab/rm.service.keytab
Keytab name: FILE:/etc/security/keytab/rm.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 rm/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 rm/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 rm/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

每个主机上的NodeManager keytab文件应如下所示：
```
$ klist -e -k -t /etc/security/keytab/nm.service.keytab
Keytab name: FILE:/etc/security/keytab/nm.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 nm/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 nm/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 nm/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

## 2.4. MapReduce JobHistory服务器

该主机上的MapReduce JobHistory Server密钥表文件应如下所示：
```
$ klist -e -k -t /etc/security/keytab/jhs.service.keytab
Keytab name: FILE:/etc/security/keytab/jhs.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 jhs/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 jhs/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 jhs/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

## 2.5. 从Kerberos principals 映射到OS用户帐户

In the default hadoop mode a Kerberos principal must be matched against a rule that transforms the principal to a simple form, i.e. a user account name without ‘@’ or ‘/’, otherwise a principal will not be authorized and a error will be logged. In case of the MIT mode the rules work in the same way as the auth_to_local in Kerberos configuration file (krb5.conf) and the restrictions of hadoop mode do not apply. If you use MIT mode it is suggested to use the same auth_to_local rules that are specified in your /etc/krb5.conf as part of your default realm and keep them in sync. In both hadoop and MIT mode the rules are being applied (with the exception of DEFAULT) to all principals regardless of their specified realm. Also, note you should not rely on the auth_to_local rules as an ACL and use proper (OS) mechanisms.

auth_to_local的可能值为：
```
RULE:exp The local name will be formulated from exp. The format for exp is [n:string](regexp)s/pattern/replacement/g. The integer n indicates how many components the target principal should have. If this matches, then a string will be formed from string, substituting the realm of the principal for $0 and the n’th component of the principal for $n (e.g., if the principal was johndoe/admin then [2:$2$1foo] would result in the string adminjohndoefoo). If this string matches regexp, then the s//[g] substitution command will be run over the string. The optional g will cause the substitution to be global over the string, instead of replacing only the first match in the string. As an extension to MIT, Hadoop auth_to_local mapping supports the /L flag that lowercases the returned name.

DEFAULT Picks the first component of the principal name as the system user name if and only if the realm matches the default_realm (usually defined in /etc/krb5.conf). e.g. The default rule maps the principal host/full.qualified.domain.name@MYREALM.TLD to system user host if the default realm is MYREALM.TLD.
```

如果未指定任何规则，则Hadoop默认使用DEFAULT，这可能不适用于大多数集群

请注意，Hadoop不支持多个默认领域（例如，像Heimdal一样）。此外，Hadoop不会在映射是否存在本地系统帐户时进行验证。

在典型的集群中，HDFS和YARN服务将分别作为系统hdfs和yarn用户启动。`hadoop.security.auth_to_local`可以配置如下：
```
<property>
  <name>hadoop.security.auth_to_local</name>
  <value>
    RULE:[2:$1/$2@$0]([ndj]n/.*@REALM.\TLD)s/.*/hdfs/
    RULE:[2:$1/$2@$0]([rn]m/.*@REALM\.TLD)s/.*/yarn/
    RULE:[2:$1/$2@$0](jhs/.*@REALM\.TLD)s/.*/mapred/
    DEFAULT
  </value>
</property>
```

这会将任何主机上的任何principalnn，dn，jn从领域REALM.TLD映射到本地系统帐户hdfs。其次，将映射任何主要RM，纳米任何关于主机从REALM.TLD到本地系统帐户Y。第三，它将任何主机上的principaljhs从领域REALM.TLD映射到mapred的本地系统帐户。最后，默认领域中任何主机上的任何principal都将映射到该principal的用户组件。

可以使用hadoop kerbname 指令 测试自定义规则。该命令允许指定一个 principals 并应用Hadoop当前的auth_to_local规则集。

## 2.6. 从用户到组的映射

可以通过`hadoop.security.group.mapping`配置系统用户到系统组的映射机制。有关详细信息，请参见[Hadoop组映射](https://hadoop.apache.org/docs/r3.1.1/hadoop-project-dist/hadoop-common/GroupsMapping.html)。

实际上，您需要使用`Kerberos`和`LDAP for Hadoop`在安全模式下管理SSO环境。

## 2.7.代理用户

代表最终用户访问Hadoop服务的某些产品（例如Apache Oozie）需要能够模拟最终用户。有关详细信息，请参见[代理用户的文档](https://hadoop.apache.org/docs/r3.2.1/hadoop-project-dist/hadoop-common/GroupsMapping.html)。

## 2.8. DataNode安全

由于DataNode数据传输协议未使用Hadoop RPC框架，因此DataNodes必须使用dfs.datanode.address和dfs.datanode.http.address指定的特权端口对自己进行身份验证。

该身份验证基于以下假设：攻击者将无法在DataNode主机上获得root特权。

当您以root用户身份执行hdfs datanode命令时，服务器进程首先绑定特权端口，然后放弃特权并以HDFS_DATANODE_SECURE_USER指定的用户帐户运行。此启动过程使用安装到JSVC_HOME的 [jsvc program](https://commons.apache.org/proper/commons-daemon/jsvc.html) 。您必须在启动时（在hadoop-env.sh中）将HDFS_DATANODE_SECURE_USER和JSVC_HOME指定为环境变量。

从2.6.0版开始，SASL可用于验证数据传输协议。在此配置中，安全集群不再需要使用jsvc作为root 启动DataNode并绑定到特权端口。要在数据传输协议上启用SASL，请在hdfs-site.xml中设置dfs.data.transfer.protection。

可以通过以下两种方式在安全模式下启动启用了SASL的DataNode：
- 1 .为dfs.datanode.address设置一个非特权端口。
- 2.将dfs.http.policy设置为HTTPS_ONLY或将dfs.datanode.http.address设置为特权端口，并确保HDFS_DATANODE_SECURE_USER和JSVC_HOME在启动时将环境变量正确地指定为环境变量（在hadoop-env.sh中）。

为了迁移使用根身份验证的现有群集，改为开始使用SASL，请首先确保已将2.6.0或更高版本部署到所有群集节点以及需要连接到该群集的任何外部应用程序。只有版本2.6.0和更高版本的HDFS客户端可以连接到使用SASL进行数据传输协议身份验证的DataNode，因此至关重要的是，所有调用者在迁移之前都必须具有正确的版本。将2.6.0版或更高版本部署到各处后，请更新所有外部应用程序的配置以启用SASL。如果为SASL启用了HDFS客户端，则它可以成功连接到以根身份验证或SASL身份验证运行的DataNode。更改所有客户端的配置可确保随后对DataNode进行的配置更改不会中断应用程序。最后，可以通过更改其配置并重新启动来迁移每个单独的DataNode。在此迁移期间，暂时混合使用根身份验证运行的某些数据节点和使用SASL身份验证运行的某些数据节点是可以接受的，因为启用了SASL的HDFS客户端可以连接到这两者。

# 三.数据保密性

## 3.1. RPC上的数据加密

在hadoop服务和客户端之间传输的数据可以在网络上加密。在core-site.xml中将hadoop.rpc.protection设置为’privacy’ 可激活数据加密。

## 3.2. Block 数据传输时数据加密。

您需要在hdfs-site.xml中将dfs.encrypt.data.transfer设置为true，以便为DataNode的数据传输协议激活数据加密。

（可选）您可以将dfs.encrypt.data.transfer.algorithm设置为3des或rc4来选择特定的加密算法。如果未指定，则使用系统上已配置的JCE默认值，通常为3DES。

将dfs.encrypt.data.transfer.cipher.suites设置为AES / CTR / NoPadding可激活AES加密。默认情况下，这是未指定的，因此不使用AES。

使用AES时，在初始密钥交换期间仍使用dfs.encrypt.data.transfer.algorithm中指定的算法。可以通过将dfs.encrypt.data.transfer.cipher.key.bitlength设置为128、192或256来配置AES密钥位长度。默认值为128。

AES提供最大的加密强度和最佳性能。目前，在Hadoop集群中更经常使用3DES和RC4。

## 3.3. HTTP上的数据加密

Web控制台和客户端之间的数据传输通过使用`SSL（HTTPS）`保护。建议使用SSL配置，但使用`Kerberos`配置`Hadoop`安全性不是必需的。

要启用HDFS守护进程，一套Web控制台SSL `dfs.http.policy`要么`HTTPS_ONLY`或`HTTP_AND_HTTPS`在`HDFS-site.xml`中。

注意KMS和HttpFS不遵守此参数。

有关分别启用基于HTTPS的KMS和基于HTTPS的HttpFS的说明，请参阅基于HTTP的[Hadoop KMS](https://hadoop.apache.org/docs/r3.2.1/hadoop-kms/index.html)和[Hadoop HDFS-Server](https://hadoop.apache.org/docs/r3.2.1/hadoop-hdfs-httpfs/ServerSetup.html) 设置。

To enable SSL for web console of YARN daemons, set `yarn.http.policy` to `HTTPS_ONLY` in `yarn-site.xml`.

To enable SSL for web console of MapReduce JobHistory server, set `mapreduce.jobhistory.http.policy` to `HTTPS_ONLY` in mapred-site.xml.

# 四. 配置

## 4.1. HDFS和 local fileSystem 路径的权限

下表列出了HDFS和 local fileSystem （在所有节点上）的各种路径以及建议的权限：

| Filesystem | Path | User:Group | Permissions |
|------------|------|------------|--------------|
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

## 4.2. 通用配置

为了在hadoop中打开RPC身份验证，请将`hadoop.security.authentication`属性的值设置为“ kerberos”，并适当地设置下面列出的与安全性相关的设置。

以下属性应位于集群中所有节点的`core-site.xml`中。

| Parameter | Value | Notes |
|-----------|-------|-------|
| hadoop.security.authentication | kerberos | simple : No authentication. (default) kerberos : Enable authentication by Kerberos. |
| hadoop.security.authorization | true | Enable RPC service-level authorization. |
| hadoop.rpc.protection | authentication | authentication : authentication only (default); integrity : integrity check in addition to authentication; privacy : data encryption in addition to integrity |
| hadoop.security.auth_to_local | RULE:exp1 RULE:exp2 … DEFAULT | The value is string containing new line characters. See Kerberos documentation for the format of exp. |
| hadoop.proxyuser.superuser.hosts | | comma separated hosts from which superuser access are allowed to impersonation. * means wildcard. |
| hadoop.proxyuser.superuser.groups	| | comma separated groups to which users impersonated by superuser belong. * means wildcard. |

## 4.3. NameNode

|Parameter | `Value | Notes |
|----------|--------|-------|
| dfs.block.access.token.enable | true | `Enable HDFS block access tokens for secure operations. |
| dfs.namenode.kerberos.principal | `nn/_HOST@REALM.TLD` | Kerberos principal name for the NameNode. |
| dfs.namenode.keytab.file | `/etc/security/keytab/nn.service.keytab` | Kerberos keytab file for the NameNode. |
| dfs.namenode.kerberos.internal.spnego.principal | `HTTP/_HOST@REALM.TLD` | The server principal used by the NameNode for web UI SPNEGO authentication. The SPNEGO server principal begins with the prefix HTTP/ by convention. If the value is `‘*’`, the web server will attempt to login with every |

以下设置允许配置对NameNode Web UI的SSL访问（可选）。

| Parameter | Value | Notes |
|-----------|-------|--------|
| dfs.http.policy | HTTP_ONLY or HTTPS_ONLY or HTTP_AND_HTTPS | HTTPS_ONLY turns off http access. This option takes precedence over the deprecated configuration dfs.https.enable and hadoop.ssl.enabled. If using SASL to authenticate data transfer protocol instead of running DataNode as root and using privileged ports, then this property must be set to HTTPS_ONLY to guarantee authentication of HTTP servers. (See dfs.data.transfer.protection.) |
| dfs.namenode.https-address | 0.0.0.0:9871 | This parameter is used in non-HA mode and without federation. See HDFS High Availability and HDFS Federation for details. |
| dfs.https.enable | true | This value is deprecated. Use dfs.http.policy |

## 4.4. Secondary NameNode
| Parameter | Value | Notes |
|-----------|-------|-------|
| dfs.namenode.secondary.http-address | 0.0.0.0:9868 | HTTP web UI address for the Secondary NameNode. |
| dfs.namenode.secondary.https-address | 0.0.0.0:9869 | HTTPS web UI address for the Secondary NameNode. |
| dfs.secondary.namenode.keytab.file | /etc/security/keytab/sn.service.keytab | Kerberos keytab file for the Secondary NameNode. |
| dfs.secondary.namenode.kerberos.principal | `sn/_HOST@REALM.TLD` | Kerberos principal name for the Secondary NameNode. |
| dfs.secondary.namenode.kerberos.internal.spnego.principal | `HTTP/_HOST@REALM.TLD` | The server principal used by the Secondary NameNode for web UI SPNEGO authentication. The SPNEGO server principal begins with the prefix HTTP/ by convention. If the value is `‘*’`, the web server will attempt to login with every principal specified in the keytab file dfs.web.authentication.kerberos.keytab. For most deployments this can be set to `${dfs.web.authentication.kerberos.principal}` i.e use the value of dfs.web.authentication.kerberos.principal. |

## 4.5. JournalNode
| Parameter | Value | Notes |
|-----------|-------|-------|
| dfs.journalnode.kerberos.principal | `jn/_HOST@REALM.TLD` | Kerberos principal name for the JournalNode. |
| dfs.journalnode.keytab.file | `/etc/security/keytab/jn.service.keytab` | Kerberos keytab file for the JournalNode. |
| dfs.journalnode.kerberos.internal.spnego.principal | `HTTP/_HOST@REALM.TLD` | The server principal used by the JournalNode for web UI SPNEGO authentication when Kerberos security is enabled. The SPNEGO server principal begins with the prefix HTTP/ by convention. If the value is `‘*’`, the web server will attempt to login with every principal specified in the keytab file dfs.web.authentication.kerberos.keytab. For most deployments this can be set to `${dfs.web.authentication.kerberos.principal}` i.e use the value of dfs.web.authentication.kerberos.principal. |
| dfs.web.authentication.kerberos.keytab | /etc/security/keytab/spnego.service.keytab | SPNEGO keytab file for the JournalNode. In HA clusters this setting is shared with the Name Nodes. |
| dfs.journalnode.https-address | 0.0.0.0:8481 | |

## 4.6. DataNode
| Parameter | Value | Notes |
|-----------|-------|-------|
| dfs.datanode.data.dir.perm | 700 |  |
| dfs.datanode.address | 0.0.0.0:1004 | 安全数据节点必须使用特权端口，以确保服务器安全启动。这意味着服务器必须通过jsvc启动。 或者，如果使用SASL对数据传输协议进行身份验证，则必须将其设置为非特权端口. (See dfs.data.transfer.protection.) |
| dfs.datanode.http.address | 0.0.0.0:1006 | 安全数据节点必须使用特权端口，以确保服务器安全启动。这意味着服务器必须通过jsvc启动。 |
| dfs.datanode.https.address | 0.0.0.0:9865 | HTTPS web UI address for the Data Node. |
| dfs.datanode.kerberos.principal | `dn/_HOST@REALM.TLD` | Kerberos principal name for the DataNode. |
| dfs.datanode.keytab.file | /etc/security/keytab/dn.service.keytab | Kerberos keytab file for the DataNode. |
| dfs.encrypt.data.transfer | false | set to true when using data encryption |
| dfs.encrypt.data.transfer.algorithm | | optionally set to 3des or rc4 when using data encryption to control encryption algorithm |
| dfs.encrypt.data.transfer.cipher.suites | | optionally set to AES/CTR/NoPadding to activate AES encryption when using data encryption |
| dfs.encrypt.data.transfer.cipher.key.bitlength | | optionally set to 128, 192 or 256 to control key bit length when using AES with data encryption |
| dfs.data.transfer.protection | | authentication : authentication only; integrity : integrity check in addition to authentication; privacy : data encryption in addition to integrity This property is unspecified by default. Setting this property enables SASL for authentication of data transfer protocol. If this is enabled, then dfs.datanode.address must use a non-privileged port, dfs.http.policy must be set to HTTPS_ONLY and the HDFS_DATANODE_SECURE_USER environment variable must be undefined when starting the DataNode process. |

## 4.7. WebHDFS
| Parameter | Value | Notes |
|-----------|-------|--------|
| dfs.web.authentication.kerberos.principal | `http/_HOST@REALM.TLD` | Kerberos principal name for the WebHDFS. In HA clusters this setting is commonly used by the JournalNodes for securing access to the JournalNode HTTP server with SPNEGO. |
| dfs.web.authentication.kerberos.keytab | /etc/security/keytab/http.service.keytab | Kerberos keytab file for WebHDFS. In HA clusters this setting is commonly used the JournalNodes for securing access to the JournalNode HTTP server with SPNEGO. |

## 4.8. ResourceManager
| Parameter | Value | Notes |
|------------|------|-------|
| yarn.resourcemanager.principal | `rm/_HOST@REALM.TLD` | Kerberos principal name for the ResourceManager. |
| yarn.resourcemanager.keytab | /etc/security/keytab/rm.service.keytab | Kerberos keytab file for the ResourceManager. |
| yarn.resourcemanager.webapp.https.address | ${yarn.resourcemanager.hostname}:8090 | The https adddress of the RM web application for non-HA. In HA clusters, use yarn.resourcemanager.webapp.https.address.rm-id for each ResourceManager. See ResourceManager High Availability for details. |

## 4.9. NodeManager
| Parameter | Value | Notes |
|-----------|-------|--------|
| yarn.nodemanager.principal | `nm/_HOST@REALM.TLD` | Kerberos principal name for the NodeManager. |
| yarn.nodemanager.keytab | /etc/security/keytab/nm.service.keytab | Kerberos keytab file for the NodeManager. |
| yarn.nodemanager.container-executor.class | org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor | Use LinuxContainerExecutor. |
| yarn.nodemanager.linux-container-executor.group | hadoop | Unix group of the NodeManager. |
| yarn.nodemanager.linux-container-executor.path | /path/to/bin/container-executor | The path to the executable of Linux container executor. |
| yarn.nodemanager.webapp.https.address | 0.0.0.0:8044 | The https adddress of the NM web application. |

## 4.10. Configuration for WebAppProxy

所述WebAppProxy提供由应用程序和终端用户导出的web应用程序之间的代理。

如果启用了安全性，它将在访问可能不安全的Web应用程序之前警告用户。使用代理的身份验证和授权的处理方式与其他任何特权Web应用程序一样。

| Parameter | Value | Notes |
|-----------|-------|--------|
| yarn.web-proxy.address | WebAppProxy host:port for proxy to AM web apps. | host:port if this is the same as yarn.resourcemanager.webapp.address or it is not defined then the ResourceManager will run the proxy otherwise a standalone proxy server will need to be launched. |
| yarn.web-proxy.keytab | /etc/security/keytab/web-app.service.keytab | Kerberos keytab file for the WebAppProxy. |
| yarn.web-proxy.principal | `wap/_HOST@REALM.TLD` | Kerberos principal name for the WebAppProxy. |

## 4.11. LinuxContainerExecutor

由ContainerExecutor使用，它限定任何如何容器推出和控制。

YARN框架使用ContainerExecutor 来启动和控制container .

以下是Hadoop YARN中可用的内容：

| ContainerExecutor | Description |
|-------------------|-------------|
| DefaultContainerExecutor | YARN默认的executor . 用于管理container 执行.容器进程与NodeManager具有相同的Unix用户。 |
| LinuxContainerExecutor | 仅仅支持GNU/Linux操作系统,此执行器以提交应用程序的用户（启用完全安全性时）或专用用户（默认为nobody）的身份（未启用完全安全性时）运行容器。启用安全认证后，此执行器要求在启动容器的群集节点上创建所有用户帐户。它使用Hadoop发行版中包含的setuid可执行文件。NodeManager使用此可执行文件启动和终止容器。setuid可执行文件将切换到提交应用程序并启动或终止容器的用户。为了最大限度地提高安全性，此执行器对容器使用的本地文件和目录（如共享对象、jar、中间文件、日志文件等）设置受限权限和用户/组所有权。特别要注意的是，正因为如此，除了应用程序所有者和节点管理员之外，没有其他用户可以访问任何本地文件/目录，包括那些作为分布式缓存的一部分本地化的文件/目录。 |

要构建LinuxContainerExecutor可执行文件，请运行：
```
mvn package -Dcontainer-executor.conf.dir=/etc/hadoop/
```

`-Dcontainer-executor.conf.dir`中传递的路径应该是setuid可执行文件的配置文件所在的群集节点上的路径。

可执行文件应安装在`$HADOOP_YARN_HOME/bin`中。

可执行文件必须具有特定的权限：`6050`或`--Sr-s ---`权限由`root`用户（超级用户）拥有，并由NodeManager Unix用户是其成员的特殊组（例如hadoop）拥有而且没有普通的应用程序用户。

如果有任何应用程序用户属于该特殊组，则安全性将受到损害。

应该在`conf/yarn-site.xml`和`conf/container-executor.cfg`中为配置属性`yarn.nodemanager.linux-container-executor.group`指定这个特殊的组名。

例如，假设`NodeManager`以用户yarn的身份运行，该用户是`AAAAA`和`hadoop`组的一部分，而其中的任何一个都是`primary group`。 假设`AAAAA`同时拥有`yarn`和另一个用户（应用程序提交者）alice作为其成员，并且alice不属于hadoop。

按照上面的描述，`setuid / setgid`可执行文件应设置为`6050`或`–Sr-s —`，`setuid / setgid`可执行文件的所有者为`yarn`和`hadoop`组, 应用的提交者所属的用户不应该隶属于hadoop用户组.

`LinuxTaskController`要求将包含并通向`yarn.nodemanager.local-dirs和yarn.nodemanager.log-dirs`中指定的目录的路径设置为755权限，如上表中目录权限所述。

- conf/container-executor.cfg

需要一个叫`container-executor.cfg`的配置文件

该可执行文件要求在传递给上述mvn目标的配置目录中存在一个名为`container-executor.cfg`的配置文件。

配置文件必须由运行NodeManager的用户拥有（在上例中为user yarn），任何人都必须归属于该用户的用户组，并且应具有权限 `0400 or r--------`。

可执行文件要求`conf/container-executor.cfg`文件中包含以下配置项。这些项目应以简单的`key=value`的形式提及，每行一个：

| Parameter | Value | Notes |
|-----------|-------|-------|
| yarn.nodemanager.linux-container-executor.group | hadoop | NodeManager所属的Unix group `container-executor`也应该属于这个组.和NodeManager中配置的的值一样.这个配置需要验证`container-executor`的访问权限 |
| banned.users | hdfs,yarn,mapred,bin | 被禁止访问的用户 |
| allowed.system.users | foo,bar | 允许的系统用户 |
| min.user.id | 1000 | 防止其他超级用户 |

概括一下，这是与LinuxContainerExecutor相关的各种路径所需的本地文件系统权限：

| Filesystem | Path | User:Group | Permissions |
|------------|------|------------|-------------|
| local | container-executor | root:hadoop | –Sr-s–* |
| local | conf/container-executor.cfg | root:hadoop | r-------* |
| local | yarn.nodemanager.local-dirs | yarn:hadoop | drwxr-xr-x |
| local | yarn.nodemanager.log-dirs | yarn:hadoop | drwxr-xr-x |

## 4.12.MapReduce JobHistory Server
| Filesystem | value | Notes |
|------------|-------|--------|
| mapreduce.jobhistory.address | MapReduce JobHistory Server host:port | Default port is 10020. |
| mapreduce.jobhistory.keytab | /etc/security/keytab/jhs.service.keytab | Kerberos keytab file for the MapReduce JobHistory Server. |
| mapreduce.jobhistory.principal | `jhs/_HOST@REALM.TLD` | Kerberos principal name for the MapReduce JobHistory Server. |

# 五. 多宿主

其中每个主机在DNS中具有多个主机名（例如，对应于公共和专用网络接口的不同主机名）的多宿主设置可能需要其他配置才能使Kerberos身份验证起作用。请参阅 [HDFS Support for Multihomed Networks](https://hadoop.apache.org/docs/r3.2.1/hadoop-project-dist/hadoop-hdfs/HdfsMultihoming.html)

# 六. 故障排除

Kerberos很难设置，也很难调试。常见的问题是
- 网络和DNS配置。
- 主机上的Kerberos配置（/etc/krb5.conf）。
- Keytab的创建和维护。
- 环境设置：JVM，用户登录名，系统时钟等。

来自JVM的错误消息实际上是毫无意义的，这无助于诊断和解决此类问题。

可以为客户端和任何服务启用额外的调试信息

- 将环境变量HADOOP_JAAS_DEBUG设置为true。
```
export HADOOP_JAAS_DEBUG=true
```

- 编辑log4j.properties文件以在DEBUG级别记录Hadoop的安全包。
```
log4j.logger.org.apache.hadoop.security=DEBUG
```

- 通过设置一些系统属性来启用JVM级调试。
```
export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true -Dsun.security.krb5.debug=true -Dsun.security.spnego.debug"
```

# 使用KDiag进行故障排除

Hadoop具有帮助验证设置的工具：KDiag

它包含一系列探针JVM的配置和环境，转储出一些系统文件（/etc/krb5.conf中，/etc/ntp.conf中），打印出一些系统状态，然后尝试登录到Kerberos作为当前用户或named keytab中的特定principal。

命令的输出可用于本地诊断，或转发给支持群集的任何人。

该KDiag命令有其自己的入口点; 通过将kdiag传递给bin / hadoop命令来调用它。因此，它将显示用于调用它的命令的kerberos客户端状态。
```
hadoop kdiag
```
该命令执行诊断成功会返回状态码0。
这并不意味着Kerberos在工作—只是KDiag命令没有从其有限的探针集中识别出任何问题。

特别是，由于它不尝试连接到任何远程服务，因此它不验证客户端是否受任何服务信任。

如果失败，则退出代码为
```
-1: the command failed for an unknown reason
41: Unauthorized (== HTTP’s 401). KDiag detected a condition which causes Kerberos to not work. Examine the output to identify the issue.
```

## 6.1. 使用
```
KDiag: Diagnose Kerberos Problems
  [-D key=value] : Define a configuration option.
  [--jaas] : Require a JAAS file to be defined in java.security.auth.login.config.
  [--keylen <keylen>] : Require a minimum size for encryption keys supported by the JVM. Default value : 256.
  [--keytab <keytab> --principal <principal>] : Login from a keytab as a specific principal.
  [--nofail] : Do not fail on the first problem.
  [--nologin] : Do not attempt to log in.
  [--out <file>] : Write output to a file.
  [--resource <resource>] : Load an XML configuration resource.
  [--secure] : Require the hadoop configuration to be secure.
  [--verifyshortname <principal>]: Verify the short name of the specific principal does not contain '@' or '/'
```

**–jaas: Require a JAAS file to be defined in java.security.auth.login.config.**

If --jaas is set, the Java system property java.security.auth.login.config must be set to a JAAS file; this file must exist, be a simple file of non-zero bytes, and readable by the current user. More detailed validation is not performed.

JAAS files are not needed by Hadoop itself, but some services (such as Zookeeper) do require them for secure operation.

**–keylen : Require a minimum size for encryption keys supported by the JVM".**
If the JVM does not support this length, the command will fail.

The default value is to 256, as needed for the AES256 encryption scheme. A JVM without the Java Cryptography Extensions installed does not support such a key length. Kerberos will not work unless configured to use an encryption scheme with a shorter key length.

**–keytab --principal : Log in from a keytab.**

Log in from a keytab as the specific principal.
```
1.The file must contain the specific principal, including any named host. That is, there is no mapping from _HOST to the current hostname.
2. KDiag will log out and attempt to log back in again. This catches JVM compatibility problems which have existed in the past. (Hadoop’s Kerberos support requires use of/introspection into JVM-specific classes).
```

**–nofail : Do not fail on the first problem**
KDiag will make a best-effort attempt to diagnose all Kerberos problems, rather than stop at the first one.

This is somewhat limited; checks are made in the order which problems surface (e.g keylength is checked first), so an early failure can trigger many more problems. But it does produce a more detailed report.

**–nologin: Do not attempt to log in.**
Skip trying to log in. This takes precedence over the --keytab option, and also disables trying to log in to kerberos as the current kinited user.

This is useful when the KDiag command is being invoked within an application, as it does not set up Hadoop’s static security state —merely check for some basic Kerberos preconditions.

**–out outfile: Write output to file.**
```
hadoop kdiag --out out.txt
```
Much of the diagnostics information comes from the JRE (to stderr) and from Log4j (to stdout). To get all the output, it is best to redirect both these output streams to the same file, and omit the --out option.
```
hadoop kdiag --keytab zk.service.keytab --principal zookeeper/devix.example.org@REALM > out.txt 2>&1
```
Even there, the output of the two streams, emitted across multiple threads, can be a bit confusing. It will get easier with practise. Looking at the thread name in the Log4j output to distinguish background threads from the main thread helps at the hadoop level, but doesn’t assist in JVM-level logging.

**–resource : XML configuration resource to load.**
To load XML configuration files, this option can be used. As by default, the core-default and core-site XML resources are only loaded. This will help, when additional configuration files has any Kerberos related configurations.
```
hadoop kdiag --resource hbase-default.xml --resource hbase-site.xml
```
For extra logging during the operation, set the logging and HADOOP_JAAS_DEBUG environment variable to the values listed in “Troubleshooting”. The JVM options are automatically set in KDiag.

**–secure: Fail if the command is not executed on a secure cluster.**
That is: if the authentication mechanism of the cluster is explicitly or implicitly set to “simple”:
```
<property>
  <name>hadoop.security.authentication</name>
  <value>simple</value>
</property>
```

Needless to say, an application so configured cannot talk to a secure Hadoop cluster.

**–verifyshortname : validate the short name of a principal**
This verifies that the short name of a principal contains neither the “@” nor “/” characters.

## 6.2. Example
```
hadoop kdiag \
  --nofail \
  --resource hdfs-site.xml --resource yarn-site.xml \
  --keylen 1024 \
  --keytab zk.service.keytab --principal zookeeper/devix.example.org@REALM
```
This attempts to to perform all diagnostics without failing early, load in the HDFS and YARN XML resources, require a minimum key length of 1024 bytes, and log in as the principal zookeeper/devix.example.org@REALM, whose key must be in the keytab zk.service.keytab
