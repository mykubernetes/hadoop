当YARN开启了HA之后，我们想要知道两个ResourceManager中哪台是ACTIVE，哪台是STANDBY状态，可以通过下面的方式来获取或切换它们的状态。

1、YARN的HA机制是配置在hadoop的etc目录下的yarn-site.xml文件中，如下示例代码：
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

2、从XML配置中可以看到两个RM的ID，我们可以使用下面的命令根据该ID获取它们的状态：
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

3、使用下面的命令可以检查RM的健康情况，当出现问题时会返回0以外的状态码：
```
#检查RM节点健康情况
yarn rmadmin -checkHealth <serviceId>
 
#使用$?获取上一个命令的返回状态，返回0表示健康，否则不健康
echo $?
```

4、手动切换两个RM的状态
```
#手动将 rm1 的状态切换到STANDBY
yarn rmadmin -transitionToStandby rm1
 
#手动将 rm2 的状态切换到ACTIVE
yarn rmadmin -transitionToActive rm2
```

5、当手动的切换到ACTIVE状态时，YARN会检查当前是否有ACTIVE的RM，这样做是为了避免出现脑裂的情况。如果想要强制切换ACTIVE状态时不检查当前是否有存活的RM可以使用-forceactive 参数（谨慎使用此参数）。
```
#手动将 rm2 的状态切换到ACTIVE，且不检查RM状态
yarn rmadmin -transitionToActive -forceactive -forcemanual rm2
```
