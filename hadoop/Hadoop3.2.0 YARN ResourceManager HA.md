# 介绍

本指南概述了YARN ResourceManager的高可用性，并详细介绍了如何配置和使用此功能。ResourceManager（RM）负责跟踪集群中的资源，以及调度应用程序（例如，MapReduce作业）。在Hadoop 2.4之前，ResourceManager是YARN集群中的单点故障。高可用性功能以Active / Standby ResourceManager对的形式添加冗余，以消除此单点故障。

# RM故障转移

ResourceManager HA通过主动/备用架构实现 - 在任何时间点，其中一个RM处于活动状态，并且一个或多个RM处于待机模式，等待活动发生任何事情时接管。转换为活动的触发器来自管理员（通过CLI）或启用自动故障转移时的集成故障转移控制器。

## 手动转换故障转移

如果未启用自动故障转移，则管理员必须手动将其中一个RM转换为活动。要从一个RM故障转移到另一个RM，它们应首先将Active-RM转换为待机状态，并将Standby-RM转换为Active。所有这些都可以使用“ yarn rmadmin”CLI完成。

## 自动故障转移

RM可以选择嵌入基于Zookeeper的ActiveStandbyElector来决定哪个RM应该是Active。当Active关闭或无响应时，另一个RM自动被选为Active，然后接管。请注意，不需要像HDFS那样运行单独的ZKFC守护程序，因为嵌入在RM中的ActiveStandbyElector充当故障检测器和领导者选择器而不是单独的ZKFC守护程序。

## RM故障转移上的客户端，ApplicationMaster和NodeManager

当存在多个RM时，客户端和节点使用的配置（yarn-site.xml）应该列出所有RM。客户端，ApplicationMaster（AM）和NodeManagers（NM）尝试以循环方式连接到RM，直到它们到达Active RM。如果活动停止，他们将恢复循环轮询，直到他们点击“新”活动。此默认重试逻辑实现为org.apache.hadoop.yarn.client.ConfiguredRMFailoverProxyProvider。您可以通过实现org.apache.hadoop.yarn.client.RMFailoverProxyProvider并将yarn.client.failover-proxy-provider的值设置为类名来覆盖逻辑。

## 恢复以前的active-RM状态

随着[ResourceManager的重新启](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/ResourceManagerRestart.html)，RM被晋升为活动状态负载RM内部状态，并继续从以前的主动离开的地方尽可能多地取决于RM重启功能操作。为先前提交给RM的每个托管应用程序生成一个新尝试。应用程序可以定期检查点，以避免丢失任何工作。必须从两个活动/备用RM中可见状态存储。目前，有两种用于持久性的RMStateStore实现 - FileSystemRMStateStore和ZKRMStateStore。该ZKRMStateStore隐式允许在任何时间点对单个RM进行写访问，因此是在HA群集中使用的推荐存储。当使用ZKRMStateStore时，不需要单独的防护机制来解决潜在的裂脑情况，其中多个RM可能潜在地承担活动角色。使用ZKRMStateStore时，建议不要在Zookeeper群集上设置“ zookeeper.DigestAuthenticationProvider.superDigest ”属性，以确保zookeeper admin无权访问YARN应用程序/用户凭据信息。

配置

大多数故障转移功能都可以使用各种配置属性进行调整。以下是 required/important 的列表。yarn-default.xml带有一个完整的旋钮列表。有关包括默认值的更多信息，请参阅[yarn-default.xml](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)。有关设置状态存储的说明，请参阅[ResourceManager Restart](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/ResourceManagerRestart.html)的文档。

| 配置属性 | 描述 |
|----------|------|
| hadoop.zk.address | ZK-quorum的地址。用于国家商店和嵌入式领导者选举。 |
| yarn.resourcemanager.ha.enabled | 启用RM HA。 |
| yarn.resourcemanager.ha.rm-ids | RM的逻辑ID列表。例如，“rm1，rm2”。 |
| yarn.resourcemanager.hostname.rm-id | 对于每个rm-id，指定RM对应的主机名。或者，可以设置RM的每个服务地址。 |
| yarn.resourcemanager.address.rm-id | 对于每个rm-id，请为客户端指定host：port以提交作业。如果设置，则覆盖yarn.resourcemanager.hostname中设置的主机名。rm-id。 |
| yarn.resourcemanager.scheduler.address.rm-id | 对于每个rm-id，为ApplicationMaster指定scheduler host：port以获取资源。如果设置，则覆盖yarn.resourcemanager.hostname中设置的主机名。rm-id。 |
| yarn.resourcemanager.resource-tracker.address.rm-id | 对于每个rm-id，指定要连接的NodeManagers的host：port。如果设置，则覆盖yarn.resourcemanager.hostname中设置的主机名。rm-id。 |
| yarn.resourcemanager.admin.address.rm-id | 对于每个rm-id，请为管理命令指定host：port。如果设置，则覆盖yarn.resourcemanager.hostname中设置的主机名。rm-id。 |
| yarn.resourcemanager.webapp.address.rm-id | 对于每个rm-id，指定RM Web应用程序的host：port对应。如果将yarn.http.policy设置为HTTPS_ONLY，则不需要此选项。如果设置，则覆盖yarn.resourcemanager.hostname中设置的主机名。rm-id。 |
| yarn.resourcemanager.webapp.https.address.rm-id | 对于每个rm-id，指定RM https Web应用程序对应的host：port。如果将yarn.http.policy设置为HTTP_ONLY，则不需要此选项。如果设置，则覆盖yarn.resourcemanager.hostname中设置的主机名。rm-id。 |
| yarn.resourcemanager.ha.id | 识别整体中的RM。这是可选的; 但是，如果设置，管理员必须确保所有RM在配置中都有自己的ID。 |
| yarn.resourcemanager.ha.automatic-failover.enabled | 启用自动故障转移; 默认情况下，仅在启用HA时启用它。 |
| yarn.resourcemanager.ha.automatic-failover.embedded | 启用自动故障转移时，使用嵌入式leader-elector选择Active RM。默认情况下，仅在启用HA时启用它。 |
| yarn.resourcemanager.cluster-id | 标识集群。由选民使用以确保RM不会接管另一个群集的Active。 |
| yarn.client.failover-proxy-provider | 客户端，AM和NM用于故障转移到Active RM的类。 |
| yarn.client.failover-max-attempts | FailoverProxyProvider应尝试进行故障转移的最大次数。 |
| yarn.client.failover-sleep-base-ms | 用于计算故障转移之间的指数延迟的睡眠基数（以毫秒为单位）。 |
| yarn.client.failover-sleep-max-ms | 故障转移之间的最长休眠时间（以毫秒为单位）。 |
| yarn.client.failover-retries | 每次尝试连接到ResourceManager的重试次数。 |
| yarn.client.failover-retries-on-socket-timeouts | 每次尝试连接到套接字超时上的ResourceManager的重试次数。 |


**示例配置**

以下是RM故障转移的最小设置示例。
```
<property>
  <name>yarn.resourcemanager.ha.enabled</name>
  <value>true</value>
</property>
<property>
  <name>yarn.resourcemanager.cluster-id</name>
  <value>cluster1</value>
</property>
 
<!-- 两个RM的ID -->
<property>
  <name>yarn.resourcemanager.ha.rm-ids</name>
  <value>rm1,rm2</value>
</property>
<property>
  <name>yarn.resourcemanager.hostname.rm1</name>
  <value>master1</value>
</property>
<property>
  <name>yarn.resourcemanager.hostname.rm2</name>
  <value>master2</value>
</property>
<property>
  <name>yarn.resourcemanager.webapp.address.rm1</name>
  <value>master1:8088</value>
</property>
<property>
  <name>yarn.resourcemanager.webapp.address.rm2</name>
  <value>master2:8088</value>
</property>
<property>
  <name>hadoop.zk.address</name>
  <value>zk1:2181,zk2:2181,zk3:2181</value>
</property>
```

**管理员命令**

yarn rmadmin有一些特定于HA的命令选项，用于检查RM的运行状况和状态，并转换为Active / Standby。HA的命令将yarn.resourcemanager.ha.rm-ids设置的RM的服务id 作为参数。

```
#获取rm1的节点状态
yarn rmadmin -getServiceState rm1
>>active
 
#获取rm2的节点状态
yarn rmadmin -getServiceState rm2
>>standby
 
#获取所有RM节点的状态
yarn rmadmin -getAllServiceState
>>rm2               standby   
>>rm1               active 
```

检查RM的健康情况，当出现问题时会返回0以外的状态码：
```
#检查RM节点健康情况
yarn rmadmin -checkHealth <serviceId>
 
#使用$?获取上一个命令的返回状态，返回0表示健康，否则不健康
echo $?
```

手动切换两个RM的状态
```
#手动将 rm1 的状态切换到STANDBY
yarn rmadmin -transitionToStandby rm1
 
#手动将 rm2 的状态切换到ACTIVE
yarn rmadmin -transitionToActive rm2
```

当手动的切换到ACTIVE状态时，YARN会检查当前是否有ACTIVE的RM，这样做是为了避免出现脑裂的情况。如果想要强制切换ACTIVE状态时不检查当前是否有存活的RM可以使用-forceactive 参数（谨慎使用此参数）。
- 如果启用了自动故障转移，则无法使用手动转换命令。虽然您可以通过-forcemanual标志覆盖它，但您需要谨慎。

```
$ yarn rmadmin -transitionToStandby rm1
Automatic failover is enabled for org.apache.hadoop.yarn.client.RMHAServiceTarget@1d8299fd
Refusing to manually manage HA state, since it may cause
a split-brain scenario or other incorrect state.
If you are very sure you know what you are doing, please
specify the forcemanual flag.
```

```
#手动将 rm2 的状态切换到ACTIVE，且不检查RM状态
yarn rmadmin -transitionToActive -forceactive -forcemanual rm2
```

有关更多详细信息，请参阅[YarnCommands](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html)。

# ResourceManager Web UI服务

假设备用RM启动并运行，备用数据库会自动将所有Web请求重定向到“活动”，“关联”页面除外。

# 网页服务

假设备用RM已启动并正在运行，则在备用RM上调用时在[ResourceManager REST API](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/ResourceManagerRest.html)中描述的RM Web服务会自动重定向到Active RM。
