# 一 .前言

## 1.1. 概念

Kerberos是一种认证机制。

目的是，通过密钥系统为客户端/服务器应用程序提供强大的认证系统：保护服务器防止错误的用户使用，同时保护它的用户使用正确的服务器，即支持双向验证；Kerberos协议的整个认证过程实现不依赖于主机操作系统的认证，无需基于主机地址的信任，不要求网络上所有主机的物理安全，并假定网络上传送的数据包可以被任意地读取、修改和插入数据，简而言之，Kerberos通过传统的加密技术（共享密钥）实现了一种可信任的第三方认证服务。
- KDC（key distribution center）：是一个网络服务，提供ticket和临时会话密钥。
- AS（Authentication Server）：认证服务器
- TGS（Ticket Grantion Server）：许可证服务器
- TGT：Ticket-grantion Ticket
- realm name：包含KDC和许多客户端的Kerberos网络，类似于域，俗称为领域；也是principal的一个“容器”或者“命名空间”。相对应的，principal的命名规则是"what_name_you_like@realm"。在kerberos，大家都约定俗成用大写来命名realm，比如“EXAMPLE.COM”
- password：某个用户的密码，对应于kerberos中的master_key。password可以存在一个keytab文件中。所以kerberos中需要使用密码的场景都可以用一个keytab作为输入。
- credential：credential是“证明某个人确定是他自己/某一种行为的确可以发生”的凭据。在不同的使用场景下，credential的具体含义也略有不同：对于某个principal个体而言，他的credential就是他的password；在kerberos认证的环节中，credential就意味着各种各样的ticket。
- authenticator：验证者，是服务器用于验证客户机用户主体的信息。验证者包含用户的主体名称、时间标记和其他数据。与票证不同，验证者只能使用一次，通常在请求访问服务时使用。
- principal：认证的主体，，也说安全个体，简单来说就是“用户名”。
- Ticket：一个记录，客户用它来向服务器证明自己的身份，包括服务的主体名称、用户的主体名称、用户主机的ip地址、时间标记、会话密钥、定义票证生命周期的时间戳。
- keytab：keytab是包含principals和加密principal key的文件。keytab文件对于每个host是唯一的，因为key中包含hostname。keytab文件用于不需要人工交互和保存纯文本密码，实现到kerberos上验证一个主机上的principal。因为服务器上可以访问keytab文件即可以以principal的身份通过kerberos的认证，所以，keytab文件应该被妥善保存，应该只有少数的用户可以访问。

## 1.2. 安装规划

| 组件 | 版本 |
|-----|-------|
| 操作系统 | Centos 7.6 |
| 操作用户 | root |
| KDC,AS,TGS | master01 |
| Kerberos Agent | master01 … |

# 二 .搭建Kerberos Server

# 2.1.使用 yum 安装Kerberos Server的套件
```
yum install -y krb5-libs krb5-server krb5-workstation
```

## 2.2. 配置 /etc/krb5.conf

我使用realms 是EXAMPLE.COM .所以配置如下:
```
vi /etc/krb5.conf

# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
 default_realm = EXAMPLE.COM
 # default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EXAMPLE.COM = {
  kdc = master01:88
  admin_server = master01:789
 }

[domain_realm]
 .henghe.com = EXAMPLE.COM
 henghe.com = EXAMPLE.COM
```

注意: default_ccache_name 一定要注释掉!!! 否者hadoop指令会报错:
```
org.apache.hadoop.security.AccessControlException: Client cannot authenticate via:[TOKEN, KERBEROS]
```

名词讲解：
```
以上相关配置参数说明：
[logging]：
　　 Kerberos守护进程的日志记录方式。换句话说，表示 server 端的日志的打印位置。
    default                         ：默认的krb5libs.log日志文件存放路径
    kdc                             ：默认的krb5kdc.log日志文件存放路径
    admin_server                    ：默认的kadmind.log日志文件存放路径

[libdefaults]：
　　 Kerberos使用的默认值，当进行身份验证而未指定Kerberos域时，则使用default_realm参数指定的Kerberos域。即每种连接的默认配置，需要注意以下几个关键的配置：
    ticket_lifetime                 ：凭证生效的时限，设置为1天。
    default_realm = EXAMPLE.COM ：设置 Kerberos 应用程序的默认领域。如果您有多个领域，只需向 [realms] 节添加其他的语句。其中EXAMPLE.COM可以为任意名字,推荐为大写。必须跟要配置的realm的名称一致。
    default_ccache_name：           ： 默认的缓存名称，[  一定要注释掉!!!!     ] 。
　　 renew_lifetime                  ：凭证最长可以被延期的时限，一般为7天。当凭证过期之后，对安全认证的服务的后续访问则会失败。
　　 forwardable                     ：如果此参数被设置为true，则可以转发票据，这意味着如果具有TGT的用户登陆到远程系统，则KDC可以颁发新的TGT，而不需要用户再次进行身份验证。
　　 renewable                       ：是否允许票据延迟

[realms]：
　　域特定的信息，例如域的Kerberos服务器的位置。可能有几个，每个域一个。可以为KDC和管理服务器指定一个端口。如果没有配置，则KDC使用端口88，管理服务器使用749。即列举使用的 realm域。
　　kdc                              ：代表要KDC的位置。格式是 机器:端口 [默认端口: 88 ]
　　admin_server                     ：代表admin的位置。格式是 机器:端口 [默认端口: 789]
   default_domain                   ：顾名思义，指定默认的域名。

[domain_realm]：
　  指定DNS域名和Kerberos域名之间映射关系。指定服务器的FQDN，对应的domain_realm值决定了主机所属的域。
　　
[kdc]：
　　kdc的配置信息。即指定kdc.conf的位置。
　　profile                          ：kdc的配置文件路径，默认值下若无文件则需要创建。
```

## 2.3. 配置 /var/kerberos/krb5kdc/kdc.conf
```
[root@master01 krb5kdc]# cat /var/kerberos/krb5kdc/kdc.conf
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 EXAMPLE.COM = {
  #master_key_type = aes256-cts
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal camellia256-cts:normal camellia128-cts:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
 }
```

以上参数说明:
```
[kdcdefaults]　 该部分包含在此文件中列出的所有通用的配置。
   kdc_ports　　　　　　　　　　     :指定KDC的默认端口。
   kdc_tcp_ports　　　　　　　   　 :指定KDC的TCP协议默认端口。

[realms]　　该部分列出每个领域的配置。
   EXAMPLE.COM   　　       ： 是设定的 realms。名字随意，推荐为大写！，但须与/etc/krb5.conf保持一致。Kerberos 可以支持多个 realms，会增加复杂度。大小写敏感。
   master_key_type　  　   ： 默认为禁用，但如果需要256为加密，则可以下载Java加密扩展（JCE）并安装。禁用此参数时，默认使用128位加密。
　　acl_file　　　　 　　    ： 标注了 admin 的用户权限的文件，若文件不存在，需要用户自己创建。即该参数允许为具有对Kerberos数据库的管理访问权限的UPN指定ACL。
   supported_enctypes　　  ： 指定此KDC支持的各种加密类型。
  　admin_keytab　　　　  　：  KDC 进行校验的 keytab。    
  　max_life　 　　　　　　  ： 该参数指定如果指定为2天。这是票据的最长存活时间。　　
  　max_renewable_life　　 ： 该参数指定在多长时间内可重获取票据。   
  　dict_file　　　 　　　　 ： 该参数指向包含潜在可猜测或可破解密码的文件。
```
注：这里需要分发krb5.conf至所有client主机

## 2.4. 配置 /var/kerberos/krb5kdc/kadm5.acl
```
[root@master01 krb5kdc]# cat /var/kerberos/krb5kdc/kadm5.acl
*/admin@EXAMPLE.COM	*
[root@master01 krb5kdc]#
```

以上参数说明：
```
上述参数只有两列，第一列为用户名，第二列为权限分配。文件格式是：Kerberos_principal permissions [target_principal] [restrictions]，下面是对上面的文件编写参数说明。
*/admin@EXAMPLE.COM     :表示以"/admin@EXAMPLE.COM"结尾的用户。
*　　　　　　　　　　　　　　　　：表示可以执行任何操作，因为权限为所有权限
```

## 2.5. 初始化Kerberos的数据库

输入: `kdb5_util create -s -r EXAMPLE.COM`

其中EXAMPLE.COM 是对应的域，如果你的不同请修改  
然后命令要求设置数据库master的密码，要求输入两次，输入 krb5kdc(自行定义) 即可 .  
这样得到 数据库master账户： K/M@EXAMPLE.COM* , 密码： krb5kdc(自行定义)  

重新初始化数据库
```
异常信息: kdb5_util: Cannot open DB2 database '/var/kerberos/krb5kdc/principal': File exists while creating database '/var/kerberos/krb5kdc/principal'
```

清理掉 /var/kerberos/krb5kdc 目录下的principal * 文件即可.
```
[root@master01 krb5kdc]# pwd
/var/kerberos/krb5kdc
[root@master01 krb5kdc]# ll
总用量 32
-rw-------  1 root root    75 3月  26 15:15 .k5.EXAMPLE.COM			                #存储文件.k5.EXAMPLE.COM，[默认隐藏]
-rw------- 1 root root    21 3月  26 15:07 kadm5.acl　　　　　　　　　　　　　　　　#定义管理员权限的配置文件
-rw------- 1 root root   450 3月  26 15:07 kdc.conf　　　　　　　　　　　　　　　　 #KDC的主配置文件
-rw------- 1 root root 16384 3月  26 15:16 principal　　　　　　　　　　　　　　　　#Kerberos数据库文件
-rw------- 1 root root  8192 3月  26 15:15 principal.kadm5　　　　　　　　　　　　　#Kerberos数据库管理文件
-rw------- 1 root root     0 3月  26 15:15 principal.kadm5.lock　　　　　　　　　  #数据库锁管理文件
-rw------- 1 root root     0 3月  26 15:16 principal.ok　　　　　　　　　　　　　　 #Kerberos数据库文件　
[root@master01 krb5kdc]#
```

## 2.6. 创建EXAMPLE.COM 域内的管理员

执行：kadmin.local 进入 kerberos 的 admin 命令行界面
```
# 输入如下内容，添加一个用户
addprinc root/admin@EXAMPLE.COM
# 要求输入密码，输入root作为密码（可自行设置）
# 上面的账户就作为EXAMPLE.COM的管理员账户存在 （满足 */admin@EXAMPLE.COM 的规则 拥有全部权限）
# 再创建一个 测试的管理员用户
addprinc krbtest/admin@EXAMPLE.COM # 同样满足 */admin@EXAMPLE.COM 密码设置为krbtest
# 查看当前拥有的所有用户
listprincs
# 退出操作
quit
```
```
名词解释: principal
可以当作是用户的意思 一个principal由3个部分组成，如下:
nn/master01@EXAMPLE.COM
也就是 account/instance@realm
其中account 表示账户名 或者服务类型
instance表示实例，一般为主机名表示 属于这个主机名下的某个账户
realm 就是域 如 EXAMPLE.COM
```
nn/master01@EXAMPLE.COM 就表示
nn 这个账户 只能在master01机器登录 EXAMPLE.COM 这个域

## 2.7. 启动KDC服务器
```
# 启用krb5kdc
systemctl enable krb5kdc 

# 重启
systemctl restart krb5kdc 

# 启动
systemctl start krb5kdc 

# 停止
systemctl stop krb5kdc 

#查看状态
systemctl status krb5kdc

#设置为开机启动
systemctl enable krb5kdc.service
```

## 2.8. 启动Kerberos服务器
```
# 启用kadmin
systemctl enable kadmin 

# 重启
systemctl restart kadmin 

# 启动
systemctl start kadmin 

# 停止
systemctl stop kadmin 

#查看状态
systemctl status kadmin


#设置为开机启动
systemctl enable kadmin.service
```

# 三 .搭建Kerberos 客户端

## 3.1. 在所有的需要开启kerberos的物理机均执行：
```
yum -y install krb5-libs krb5-workstation
```

## 3.2. 同步krb5.conf配置文件

- 从server机器将 /etc/krb5.conf 复制到各个客户端同样的位置

## 3.3. 测试登录admin

执行 kinit krbtest/admin@EXAMPLE.COM 输入密码  
正确的结果就是没有任何反应  
然后输入 klist  
正确应该可以得到如下输出:
```
[root@master01 krb5kdc]# klist
Ticket cache: KEYRING:persistent:0:0
Default principal: krbtest/admin@EXAMPLE.COM

Valid starting       Expires              Service principal
2021-03-26T15:40:57  2021-03-27T15:40:57  krbtgt/EXAMPLE.COM@EXAMPLE.COM
```

# 四 .KDC常用操作

## 4.1.指令预览
```
1) kadmin.local:                打开KDC控制台，需要root权限 . 输入“?”可以查看命令列表。
2) [addprinc <principal>]：     添加Principal, 在KDC控制台使用， 执行后需要两次输入该Principal的密码。
3) [delprinc <principal>]：     删除Principal, 在KDC控制台使用， 执行后需要确认是否删除。
4) [xst -k <keytab file path> <principal>] ：   导出指定Principal到指定 Keytab文件， 在KDC控制台使用。如果指定的Keytab文件已存在，则会将指定Principal信息合并至Keytab文件中。
5) [modprinc -<parameter> <parameter value> <principal>]：   针对指定的Principal进行某项参数的修改，在KDC控制台使用。需要注意的是，使用modprinc命令修改的参数，优先级会比kdc.conf中的高。
6) [getprinc <principal>]：     查看指定Principal的信息，包括每种密钥的加密类型、KVNO标签等，在KDC控制台使用。
7) [listprincs]：               列出所有Principal, 在KDC控制台使用。
```

## 4.2. 进入本地管理员模式[ kadmin.local]

- kadmin.local
```
[root@master01 krb5kdc]# kadmin.local
Authenticating as principal root/admin@EXAMPLE.COM with password.
kadmin.local:  listprincs
K/M@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/master01@EXAMPLE.COM
kiprop/master01@EXAMPLE.COM
krbtest/admin@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
root/admin@EXAMPLE.COM
kadmin.local:
```

## 4.3. 查看已经存在的凭据 [listprincs]

- listprincs
```
[root@master01 krb5kdc]# kadmin.local
Authenticating as principal root/admin@EXAMPLE.COM with password.
kadmin.local:  listprincs
K/M@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/master01@EXAMPLE.COM
kiprop/master01@EXAMPLE.COM
krbtest/admin@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
root/admin@EXAMPLE.COM
kadmin.local:
```

## 4.4. 创建凭据 [addprinc]

- addprinc -randkey test/master01@EXAMPLE.COM
```
[root@master01 krb5kdc]# kadmin.local
Authenticating as principal root/admin@EXAMPLE.COM with password.
kadmin.local:  listprincs
K/M@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/master01@EXAMPLE.COM
kiprop/master01@EXAMPLE.COM
krbtest/admin@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
root/admin@EXAMPLE.COM
kadmin.local:

kadmin.local:  addprinc -randkey test/master01@EXAMPLE.COM
WARNING: no policy specified for test/master01@EXAMPLE.COM; defaulting to no policy
Principal "test/master01@EXAMPLE.COM" created.
kadmin.local:
kadmin.local:  listprincs
K/M@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/master01@EXAMPLE.COM
kiprop/master01@EXAMPLE.COM
krbtest/admin@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
root/admin@EXAMPLE.COM
test/master01@EXAMPLE.COM
kadmin.local:
```

## 4.5. 删除凭据 [delprinc]

- delprinc test/master01@EXAMPLE.COM
```
kadmin.local:  delprinc test/master01@EXAMPLE.COM
Are you sure you want to delete the principal "test/master01@EXAMPLE.COM"? (yes/no): yes
Principal "test/master01@EXAMPLE.COM" deleted.
Make sure that you have removed this principal from all ACLs before reusing.
kadmin.local:  listprincs
K/M@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/master01@EXAMPLE.COM
kiprop/master01@EXAMPLE.COM
krbtest/admin@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
root/admin@EXAMPLE.COM
kadmin.local:
```

## 4.6. 导出某个用户的keytab证书 [ ktadd / xst]

### 4.6.1. 使用ktadd 导出

- ktadd -k /opt/keytab/root.keytab root/admin@EXAMPLE.COM
```
kadmin.local: ktadd -k /opt/keytab/root.keytab root/admin@EXAMPLE.COM
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type des3-cbc-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type arcfour-hmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type camellia256-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type camellia128-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type des-hmac-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 2, encryption type des-cbc-md5 added to keytab WRFILE:/opt/keytab/root.keytab.
kadmin.local:
```

### 4.6.2. 使用xst 导出

- xst -k /opt/keytab/root.keytab root/admin@EXAMPLE.COM
```
kadmin.local:  xst -k  /opt/keytab/root.keytab root/admin@EXAMPLE.COM
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type des3-cbc-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type arcfour-hmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type camellia256-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type camellia128-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type des-hmac-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type des-cbc-md5 added to keytab WRFILE:/opt/keytab/root.keytab.
kadmin.local:
```

### 4.6.3 验证
```
[root@master01 keytab]# klist -k -e -t /opt/keytab/root.keytab
Keytab name: FILE:root.keytab
KVNO Timestamp           Principal
---- ------------------- ------------------------------------------------------
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des3-cbc-sha1)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (arcfour-hmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (camellia256-cts-cmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (camellia128-cts-cmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des-hmac-sha1)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des-cbc-md5)
```

## 4.7 . 导出多个用户的keytab文件

- xst -norandkey -k /opt/keytab/root.keytab root/admin@EXAMPLE.COM krbtest/admin@EXAMPLE.COM
```
kadmin.local:
kadmin.local:  xst -norandkey -k /opt/keytab/root.keytab root/admin@EXAMPLE.COM krbtest/admin@EXAMPLE.COM
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type des3-cbc-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type arcfour-hmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type camellia256-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type camellia128-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type des-hmac-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal root/admin@EXAMPLE.COM with kvno 4, encryption type des-cbc-md5 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type des3-cbc-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type arcfour-hmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type camellia256-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type camellia128-cts-cmac added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type des-hmac-sha1 added to keytab WRFILE:/opt/keytab/root.keytab.
Entry for principal krbtest/admin@EXAMPLE.COM with kvno 1, encryption type des-cbc-md5 added to keytab WRFILE:/opt/keytab/root.keytab.
kadmin.local:
```

查看
```
[root@master01 keytab]# klist -k -e -t /opt/keytab/root.keytab
Keytab name: FILE:root.keytab
KVNO Timestamp           Principal
---- ------------------- ------------------------------------------------------
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des3-cbc-sha1)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (arcfour-hmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (camellia256-cts-cmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (camellia128-cts-cmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des-hmac-sha1)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des-cbc-md5)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (des3-cbc-sha1)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (arcfour-hmac)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (camellia256-cts-cmac)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (camellia128-cts-cmac)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (des-hmac-sha1)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (des-cbc-md5)
```

## 4.8. 获取凭据信息[getprinc]

- getprinc root/admin@EXAMPLE.COM
```
[root@master01 krb5kdc]# kadmin.local
Authenticating as principal root/admin@EXAMPLE.COM with password.
kadmin.local:   getprinc  root/admin@EXAMPLE.COM
Principal: root/admin@EXAMPLE.COM
Expiration date: [never]
Last password change: 五 3月 26 18:00:07 CST 2021
Password expiration date: [never]
Maximum ticket life: 1 day 00:00:00
Maximum renewable life: 0 days 00:00:00
Last modified: 五 3月 26 18:00:07 CST 2021 (root/admin@EXAMPLE.COM)
Last successful authentication: [never]
Last failed authentication: [never]
Failed password attempts: 0
Number of keys: 8
Key: vno 4, aes256-cts-hmac-sha1-96
Key: vno 4, aes128-cts-hmac-sha1-96
Key: vno 4, des3-cbc-sha1
Key: vno 4, arcfour-hmac
Key: vno 4, camellia256-cts-cmac
Key: vno 4, camellia128-cts-cmac
Key: vno 4, des-hmac-sha1
Key: vno 4, des-cbc-md5
MKey: vno 1
Attributes:
Policy: [none]
kadmin.local:
```

## 4.9. 退出 [quit]

```
[root@master01 krb5kdc]# kadmin.local
Authenticating as principal root/admin@EXAMPLE.COM with password.
kadmin.local:  listprincs
K/M@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/master01@EXAMPLE.COM
kiprop/master01@EXAMPLE.COM
krbtest/admin@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
root/admin@EXAMPLE.COM
kadmin.local:  quit
[root@master01 krb5kdc]#
```

# 五 .Client常用操作

## 5.1.指令预览
```
1) klist:列出当前系统用户的 Kerberos认证情况。
2) klist -kt <keytab file path>：列出指定 keytab文件中包含的Principal信息， 需要该文件的读权限。
3) kinit <principal>：使用输入密码的方式认证指定的Principal。
4) kinit -kt <keytab file path> <principal>：使用指定 keytab中的指定Principal进行认证， 需要该文件的读权限。
5) kdestory:注销当前已经认证的Principal。

6) ktutil:进入 keytab工具控制台。
7) [list] [1]：列出当前 ktutil中的密钥表。
8) [clear] [clear_list]：清除当前密钥表。
9) [rkt \<keytab file path>]：读取一个keytab中的所有Principal信息到密钥表， 需要有该文件的读权限 ， 在ktutil中使用。
10) [wkt \<keytab file path>]：将密钥表中的所有Principal信息写入指定文件中。 如果文件已存在， 则需要该文件的写权限， 信息会附加至文件末， 在ktutil中使用。
11) [addent -password -p \<principal> -k <KVNO> -e <enctype>] ： 手 动 添 加一条Principal信息到密钥表 ， 执行后需要输入指定Principal的密码。 由于手动添加的信息 ktutil不会进行验证， 因此不推荐使用。
12) [delent \<entity number>]：从密钥表中删除指定行号的Principal信息， 行号可使用list或l命令查看， 在ktutil中使用。
13) [Ir] [Iist_request]：列出所有 ktutil中可用的命令， 在ktutiJ中使用。
14) [quit] [q] [exit]：退出ktutil控制台。
```

## 5.2.查看当前客户端认证用户 [klist]
```
[root@master01 krb5kdc]#
[root@master01 krb5kdc]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: root/admin@EXAMPLE.COM

Valid starting       Expires              Service principal
2021-03-26T17:36:05  2021-03-27T17:36:05  krbtgt/EXAMPLE.COM@EXAMPLE.COM
[root@master01 krb5kdc]#
```

## 5.3.删除当前的认证的缓存 [ kdestroy]
```
[root@master01 krb5kdc]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: root/admin@EXAMPLE.COM

Valid starting       Expires              Service principal
2021-03-26T17:36:05  2021-03-27T17:36:05  krbtgt/EXAMPLE.COM@EXAMPLE.COM

[root@master01 krb5kdc]# kdestroy
Other credential caches present, use -A to destroy all

[root@master01 krb5kdc]# klist
klist: Credentials cache keyring 'persistent:0:krb_ccache_MkHX3zi' not found
[root@master01 krb5kdc]#
```

## 5.4.导出keytab文件 [ktutil ]
```
[root@master01]# ktutil
ktutil:  add_entry -password -p root/admin@EXAMPLE.COM -k 1 -e aes128-cts-hmac-sha1-96
Password for root/admin@EXAMPLE.COM:
ktutil:  wkt /opt/keytab/root.keytab
ktutil:  q
[root@master01]#
```

## 5.5.根据keytab认证用户 [kinit]

- kinit -kt /opt/keytab/root.keytab root/admin@EXAMPLE.COM
```
[root@master01 krb5kdc]# kinit -kt /opt/keytab/root.keytab  root/admin@EXAMPLE.COM
[root@master01 krb5kdc]# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_MkHX3zi
Default principal: root/admin@EXAMPLE.COM

Valid starting       Expires              Service principal
2021-03-26T18:14:28  2021-03-27T18:14:28  krbtgt/EXAMPLE.COM@EXAMPLE.COM
[root@master01 krb5kdc]#
```

- `kinit root/admin@EXAMPLE.COM` 无法用密码登录.

遇到上述问题的解决方案（原因：每次生成秘钥文件时，密码可能会进行随机改变，添加"-norandkey"即可解决问题！）
```
kadmin.local: ktadd -k /opt/keytab/root.keytab -norandkey root/admin@EXAMPLE.COM
```

## 5.6.修改Kerberos用户的密码 [kpasswd]
```
kpasswd root/admin@EXAMPLE.COM
```

## 5.7.查看keytab文件中的帐号列表 [klist]
```
klist -ket /opt/keytab/root.keytab

[root@master01 keytab]# klist -ket /opt/keytab/root.keytab
Keytab name: FILE:/opt/keytab/root.keytab
KVNO Timestamp           Principal
---- ------------------- ------------------------------------------------------
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des3-cbc-sha1)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (arcfour-hmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (camellia256-cts-cmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (camellia128-cts-cmac)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des-hmac-sha1)
   4 2021-03-26T18:02:53 root/admin@EXAMPLE.COM (des-cbc-md5)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (aes128-cts-hmac-sha1-96)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (des3-cbc-sha1)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (arcfour-hmac)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (camellia256-cts-cmac)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (camellia128-cts-cmac)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (des-hmac-sha1)
   1 2021-03-26T18:02:53 krbtest/admin@EXAMPLE.COM (des-cbc-md5)
[root@master01 keytab]#
```

## 5.8.生成dump文件

kdb5_util dump /opt/keytab/kerberos
```
[root@master01 keytab]# kdb5_util dump /opt/keytab/kerberos
[root@master01 keytab]# ll
总用量 16
-rw------- 1 root root 7851 3月  26 18:22 kerberos
-rw------- 1 root root    1 3月  26 18:22 kerberos.dump_ok
-rw------- 1 root root 1098 3月  26 18:02 root.keytab
[root@master01 keytab]#
```

# 六 . 参考文章
- https://www.cnblogs.com/swordfall/p/12009716.html
- https://www.cnblogs.com/yinzhengjie/p/10765503.html
- kerberos的官方地址：http://web.mit.edu/kerberos/
