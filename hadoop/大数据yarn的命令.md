- [Overview](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#Overview)
- [User Commands](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#User_Commands)
  - [application or app](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#application_or_app)
  - [applicationattempt](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#applicationattempt)
  - [classpath](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#classpath)
  - [container](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#container)
  - [jar](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#jar)
  - [logs](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#logs)
  - [node](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#node)
  - [queue](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#queue)
  - [version](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#version)
  - [envvars](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#envvars)
- [Administration Commands](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#Administration_Commands)
  - [daemonlog](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#daemonlog)
  - [nodemanager](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#nodemanager)
  - [proxyserver](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#proxyserver)
  - [resourcemanager](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#resourcemanager)
  - [rmadmin](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#rmadmin)
  - [schedulerconf](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#schedulerconf)
  - [scmadmin](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#scmadmin)
  - [sharedcachemanager](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#sharedcachemanager)
  - [timelineserver](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#timelineserver)
  - [registrydns](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#registrydns)
- [Files](https://hadoop.apache.org/docs/r3.2.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#Files)
 

# 一、概观   

YARN命令由 bin/yarn 脚本调用。不带任何参数运行yarn脚本会打印所有命令的描述。

用法: `yarn [SHELL_OPTIONS] COMMAND [GENERIC_OPTIONS] [SUB_COMMAND] [COMMAND_OPTIONS]`

YARN有一个选项解析框架，它使用解析通用选项以及运行类。

| 命令选项 | 描述 |
|---------|------|
| SHELL_OPTIONS | 常见的shell选项集。这些内容记录在“[命令手册](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/CommandsManual.html#Shell_Options)”页面上。 |
| GENERIC_OPTIONS | 多个命令支持的通用选项集。有关更多信息，请参阅“Hadoop 命令手册 ”。 |
| COMMAND COMMAND_OPTIONS | 以下各节介绍了各种命令及其选项。这些命令已分组为“ 用户命令”和“ 管理命令”。 |

# 二、用户命令

对Hadoop集群用户操作命令。

## application 应用程序或应用

用法: `yarn application [options] Usage: yarn app [options]`

| 命令选项 | 描述 |
|---------|------|
| `-appId <ApplicationId>` | 指定要操作的应用程序ID |
| `-appStates <States>` | 与-list一起使用，根据输入逗号分隔的应用程序状态列表过滤应用程序。有效的应用程序状态可以是以下之一：ALL，NEW，NEW_SAVING，SUBMITTED，ACCEPTED，RUNNING，FINISHED，FAILED，KILLED |
| `-appTags <Tags>` | 与-list一起使用，根据输入逗号分隔的应用程序标签列表过滤应用程序。 |
| `-appTypes <Types>` | 与-list一起使用，根据输入逗号分隔的应用程序类型列表过滤应用程序。 |
| `-changeQueue <QueueName>` | 将应用程序移动到新队列。可以使用'appId'选项传递ApplicationId。'movetoqueue'命令已弃用，此新命令'changeQueue'执行相同的功能。 |
| `-component <Component Name> <Count>` | 使用-flex选项可更改为应用程序/长期运行的服务运行的组件/容器的数量。支持绝对或相对变化，例如+1,2或-3。 |
| `-destroy <Application Name>` | 销毁已保存的应用程序规范并永久删除所有应用程序数据。支持-appTypes选项以指定要使用的客户端实现。 |
| `-enableFastLaunch` | 将AM依赖项上载到HDFS，以便将来更快地启动。支持-appTypes选项以指定要使用的客户端实现。 |
| `-flex <Application Name or ID>` | 更改应用程序/长时间运行的服务的组件的正在运行的容器的数量。需要-component选项。如果提供了name，则必须提供appType，除非它是默认的yarn-service。如果提供了ID，则会查找appType。支持-appTypes选项以指定要使用的客户端实现。 |
| `-help` | 显示所有命令的帮助。 |
| `-kill <Application ID>` | 杀死该应用程序。应用程序集可以与空间分开提供 |
| `-launch <ApplicationName> <File Name>` | 从规范文件启动应用程序（保存规范并启动应用程序）。可以指定选项-updateLifetime和-changeQueue来更改文件中提供的值。支持-appTypes选项以指定要使用的客户端实现。 |
| `-list` | 列出申请。支持可选地使用-appTypes根据应用程序类型筛选应用程序，-appStates根据应用程序状态筛选应用程序，-appTags根据应用程序标签筛选应用程序。 |
| `-movetoqueue <Application ID>` | 将应用程序移动到其他队列。弃用命令。请改用“changeQueue”。 |
| `-queue <Queue Name>` | 使用movetoqueue命令指定将应用程序移动到哪个队列。 |
| `-save <Application Name> <File Name>` | 保存应用程序的规范文件。可以指定选项-updateLifetime和-changeQueue来更改文件中提供的值。支持-appTypes选项以指定要使用的客户端实现。 |
| `-start <Application Name>` | 启动以前保存的应用程序。支持-appTypes选项以指定要使用的客户端实现。 |
| `-status <ApplicationId或ApplicationName>` | 打印应用程序的状态。如果提供了应用程序ID，则会打印通用YARN应用程序状态。如果提供了name，它将根据应用程序自己的实现打印应用程序特定的状态，并且必须指定-appTypes选项，除非它是默认的yarn-service类型。 |
| `-stop <Application Name or ID>` | 优雅地停止应用程序（稍后可能会再次启动）。如果提供了name，则必须提供appType，除非它是默认的yarn-service。如果提供了ID，则会查找appType。支持-appTypes选项以指定要使用的客户端实现。 |
| `-updateLifetime <Timeout>` | 从NOW更新应用程序的超时。可以使用'appId'选项传递ApplicationId。超时值以秒为单位。 |
| `-updatePriority <Priority>` | 更新应用程序的优先级。可以使用'appId'选项传递ApplicationId。 |

打印应用程序报告/终止应用程序/管理长时间运行的应用程序

## applicationattempt

U用法: `yarn applicationattempt [options]`

| 命令选项 | 描述 |
|---------|------|
| `-help` | Help |
| `-list <ApplicationId>` | 列出给定应用程序的应用程序尝试。 |
| `-status <Application Attempt Id>` | 打印应用程序尝试的状态。 |

prints applicationattempt(s) report

## classpath

用法：`yarn classpath [--glob | --jar <path> | -h | --help]`

| 命令选项 | 描述 |
|---------|------|
| --glob | 扩展通配符 |
| --path | 将类路径写为jar命名路径中的清单 |
| -h， - help | 打印帮助 |

打印获取Hadoop jar和所需库所需的类路径。如果不带参数调用，则打印由命令脚本设置的类路径，该脚本可能在类路径条目中包含通配符。其他选项在通配符扩展后打印类路径，或将类路径写入jar文件的清单中。后者在无法使用通配符且扩展类路径超过支持的最大命令行长度的环境中非常有用。

## container

用法: `yarn container [options]`

| 命令选项 | 描述 |
|---------|------|
| `-help` | 帮助 |
| `-list <Application Attempt Id >` | 列出应用程序尝试的容器。 |
| `-status <ContainerId>` | 打印容器的状态。 |

打印容器报告

## jar

用法: `yarn jar <jar> [mainClass] args...`

运行一个jar文件。用户可以将其YARN代码捆绑在jar文件中，并使用此命令执行它。

## logs

用法: `yarn logs -applicationId <application ID> [options]`

| 命令选项 | 描述 |
|---------|------|
| `-applicationId <application ID>` | 指定应用程序ID |
| `-appOwner <AppOwner>` | AppOwner（如果未指定，则假定为当前用户） |
| `-containerId <ContainerId>` | ContainerId（如果指定了节点地址，则必须指定） |
| `-help` | help |
| `-nodeAddress <NodeAddress>` | NodeAddress的格式为nodename：port（如果指定了容器id，则必须指定） |

Dump the container logs

## node

用法: `yarn node [options]`

| 命令选项 | 描述 |
|---------|------|
| `-all` | 使用-list列出所有节点。 |
| `-list` | 列出所有正在运行的节点。支持可选使用-states根据节点状态过滤节点，-all列出所有节点。 |
| `-states <States>` | 使用-list根据输入的逗号分隔的节点状态列表过滤节点。 |
| `-status <NodeId>` | 打印节点的状态报告。 |

Prints node report(s)

## queue

用法: `yarn queue [options]`

| 命令选项 | 描述 |
|---------|------|
| `-help` | help |
| `-status <QueueName>` | 打印队列的状态。 |

Prints queue information

## version

用法: `yarn version`

Prints the Hadoop version.

 

## envvars

用法: `yarn envvars`

显示计算的Hadoop环境变量。

 
# 三、管理命令

- 对Hadoop集群的管理员有用的命令。

## daemonlog

获取/设置守护程序中由限定类名称标识的日志的日志级别。有关更多信息，请参阅“[Hadoop 命令手册](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/CommandsManual.html#daemonlog)”。

## nodemanager

用法: `yarn nodemanager`

Start the NodeManager

## proxyserver

用法：`yarn proxyserver`

启动Web代理服务器

## resourcemanager

用法：`yarn resourcemanager [-format-state-store]`

| 命令选项 | 描述 |
|---------|------|
| `-format-state-store` | 格式化RMStateStore。这将清除RMStateStore，并且在不再需要过去的应用程序时非常有用。这应该仅在ResourceManager未运行时运行。 |
| `-remove-application-from-state-store <appId>` | 从RMStateStore中删除该应用程序。这应该仅在ResourceManager未运行时运行。 |

启动ResourceManager

## rmadmin

用法：
```
 Usage: yarn rmadmin
     -refreshQueues
     -refreshNodes [-g|graceful [timeout in seconds] -client|server]
     -refreshNodesResources
     -refreshSuperUserGroupsConfiguration
     -refreshUserToGroupsMappings
     -refreshAdminAcls
     -refreshServiceAcl
     -getGroups [username]
     -addToClusterNodeLabels <"label1(exclusive=true),label2(exclusive=false),label3">
     -removeFromClusterNodeLabels <label1,label2,label3> (label splitted by ",")
     -replaceLabelsOnNode <"node1[:port]=label1,label2 node2[:port]=label1,label2"> [-failOnUnknownNodes]
     -directlyAccessNodeLabelStore
     -refreshClusterMaxPriority
     -updateNodeResource [NodeID] [MemSize] [vCores] ([OvercommitTimeout]) or -updateNodeResource [NodeID] [ResourceTypes] ([OvercommitTimeout])
     -transitionToActive [--forceactive] <serviceId>
     -transitionToStandby <serviceId>
     -failover [--forcefence] [--forceactive] <serviceId> <serviceId>
     -getServiceState <serviceId>
     -getAllServiceState
     -checkHealth <serviceId>
     -help [cmd]
```

| 命令选项 | 描述 |
|---------|------|
| `-refreshQueues` | 重新加载队列的acls，状态和调度程序特定属性。ResourceManager将重新加载mapred-queues配置文件。 |
| `-refreshNodes [-g \| graceful [timeout in seconds] -client \| server]` | 在ResourceManager中刷新主机信息。这里[-g \| graceful [timeout in seconds] -client \| server]是可选的，如果我们指定超时，那么ResourceManager将等待超时，然后将NodeManager标记为退役。-client服务器指示是否应由客户端或ResourceManager处理超时跟踪。客户端跟踪是阻止，而服务器端跟踪则不是。省略超时或超时-1表示无限超时。已知问题：如果发生RM HA故障转移，服务器端跟踪将立即停用。 | | |
| `-refreshNodesResources` | 在ResourceManager刷新NodeManagers的资源。 |
| `-refreshSuperUserGroupsConfiguration` | 刷新超级用户代理组映射。 |
| `-refreshUserToGroupsMappings` | 刷新用户到组的映射。 |
| `-refreshAdminAcls` | 刷新acls以管理ResourceManager |
| `-refreshServiceAcl` | 重新加载服务级别授权策略文件ResourceManager将重新加载授权策略文件。 |
| `-getGroups [username]` | 获取指定用户所属的组。 |
| `-addToClusterNodeLabels <“label1（exclusive = true），label2（exclusive = false），label3”>` | 添加到群集节点标签。默认排他性为真。 |
| `-removeFromClusterNodeLabels <label1，label2，label3>(abel splitted by “,”)` | 从群集节点标签中删除。 |
| `-replaceLabelsOnNode <“node1 [：port] = label1，label2 node2 [：port] = label1，label2”> [-failOnUnknownNodes]` | 替换节点上的标签（请注意，我们暂时不支持在单个主机上指定多个标签。）-failOnUnknownNodes是可选的，当我们设置此选项时，如果指定的节点未知，它将失败。 |
| `-directlyAccessNodeLabelStore` | 这是DEPRECATED，将在以后的版本中删除。直接访问节点标签存储，使用此选项，所有与节点标签相关的操作都不会连接RM。相反，他们将直接访问/修改存储的节点标签。默认情况下，它为false（通过RM访问）。并请注意：如果您将yarn.node-labels.fs-store.root-dir配置为本地目录（而不是NFS或HDFS），则此选项仅在命令在运行RM的计算机上运行时才有效。 | |
| `-refreshClusterMaxPriority` | 刷新群集最高优先级 |
| `-updateNodeResource [NodeID] [MemSize] [vCores]（[OvercommitTimeout]）` | 更新特定节点上的资源。 |
| `-updateNodeResource [NodeID] [ResourceTypes]（[OvercommitTimeout]）` | 更新特定节点上的资源类型。资源类型是资源管理器中可用资源的逗号分隔键值对。例如，memory-mb = 1024Mi，vcores = 1，resource1 = 2G，resource2 = 4m |
| `-transitionToActive [-forceactive] [-forcemanual] <serviceId>` | 将服务转换为活动状态。如果使用-forceactive选项，请尝试使目标处于活动状态，而不检查是否存在活动节点。如果启用了自动故障转移，则无法使用此命令。虽然您可以通过-forcemanual选项覆盖它，但您需要谨慎。如果启用了自动故障转移，则无法使用此命令。 | |
| `-transitionToStandby [-forcemanual] <serviceId>` | 将服务转换为待机状态。如果启用了自动故障转移，则无法使用此命令。虽然您可以通过-forcemanual选项覆盖它，但您需要谨慎。 |
| `-failover [-forceactive] <serviceId1> <serviceId2>` | 启动从serviceId1到serviceId2的故障转移。如果使用-forceactive选项，即使未准备好，也要尝试故障转移到目标服务。如果启用了自动故障转移，则无法使用此命令。 |
| `-getServiceState <serviceId>` | 返回服务的状态。 |
| `-getAllServiceState` | 返回所有服务的状态。 |
| `-checkHealth <serviceId>` | 请求服务执行运行状况检查。如果检查失败，RMAdmin工具将以非零退出代码退出。 |
| `-help [cmd]` | 显示给定命令或所有命令的帮助（如果未指定）。 |
  
运行ResourceManager管理客户端

## schedulerconf

用法：`yarn schedulerconf [options]`

| 命令选项 | 描述 |
|---------|------|
| `-add <“queuePath1：key1 = val1，key2 = val2; queuePath2：key3 = val3”>` | 分号分隔要添加的队列值及其队列配置。此示例添加队列“queuePath1”（完整路径名），其具有队列配置key1 = val1和key2 = val2。它还添加队列“queuePath2”，其具有队列配置key3 = val3。 |
| `-remove <“queuePath1; queuePath2”>` | 分号分隔队列以删除。此示例删除queuePath1和queuePath2队列（完整路径名）。注意：队列必须在删除之前进入STOPPED状态。 |
| `-update <“queuePath1：key1 = val1，key2 = val2; queuePath2：key3 = val3”>` | 分号分隔的队列值，其配置应更新。此示例为queuePath1（完整路径名）的队列配置设置key1 = val1和key2 = val2，并为queuePath2的队列配置设置key3 = val3。 |
| `-global <key1 = val1，key2 = val2>` | 更新调度程序全局配置。此示例为调度程序的全局配置设置key1 = val1和key2 = val2。 |

更新调度程序配置。请注意，此功能处于alpha阶段，可能会发生变化。

## scmadmin

用法: yarn scmadmin [options]

| 命令选项 | 描述 |
|---------|------|
| -help | help |
| -runCleanerTask | 运行更干净的任务 |

运行Shared Cache Manager管理客户端

## sharedcachemanager

用法: `yarn sharedcachemanager`

启动共享缓存管理器

## timelineserver

用法: `yarn timelineserver`

启动TimeLineServer

## registrydns
用法: yarn registrydns

启动RegistryDNS服务器

# 四、档

| 命令选项 | 描述 |
|---------|------|
| etc/hadoop/hadoop-env.sh | 此文件存储所有Hadoop shell命令使用的全局设置。 |
| etc/hadoop/yarn-env.sh | 此文件存储所有YARN shell命令使用的替代。 |
| etc/hadoop/hadoop-user-functions.sh | 此文件允许高级用户覆盖某些shell功能。 |
| ~/.hadooprc | 这为个人用户存储个人环境。它在hadoop-env.sh，hadoop-user-functions.sh和yarn-env.sh文件之后处理，并且可以包含相同的设置。 |
 

 

 

原文链接: https://hadoop.apache.org/docs/r3.2.0/
