# 一、FIFO(先进先出)调度器

单队列，按照提交作业的先后顺序运行。

# 二、容量调度器(capacity scheduler)

## 1.特点

- 1）多队列：每个队列配置一定的资源量，每个队列采用FIFO的调度策略。
- 2）容量保证：管理员可为每个队列设置资源最低保证和资源使用上限。
- 3）灵活性：如果一个队列中的资源有剩余，可以暂时共享给资源不足的队列，如果该队列有新的job提交，则资源会被归还。
- 4）多租户：为了防止一个用户的作业独占某队列中的资源，该调度器会对同一用户提交的作业所占资源进行限定。

## 2.如何分配

优先选择资源占用率最低的队列,之后按照提交作业的优先级和提交时间顺序分配资源。如果相同则按照数据本地行原则：在同一节点、同一机架。

# 三、公平调度器（fair scheduler）

## 1.特点（同容量调度器）

- 1）多队列：支持多队列。
- 2）容量保证：管理员可为每个队列设置资源最低保证和资源使用上限。
- 3）灵活性：如果一个队列中的资源有剩余，可以暂时共享给资源不足的队列，如果该队列有新的job提交，则资源会被归还。
- 4）多租户：为了防止一个用户的作业独占某队列中的资源，该调度器会对同一用户提交的作业所占资源进行限定。

## 2.与容量调度器的不同点

### 1）核心调度策略不同

- 容量调度器：优先选择资源利用率低的队列。
- 公平调度器:优先选择对资源的缺额比例大的。

### 2）每个队列就可以单独设置资源分配方式

- 容量调度器：FIFO、DRF（内存CPU使用情况）
- 公平调度器：FIFO、FAIR、DRF（一般是只考虑带宽，但这里是CPU+带宽+望路宽带一起考虑）

## 3.如何分配

公平调度器设计的目标是：在时间尺度上，所有作业获得公平的资源。某一时刻一个作业应获资源和实际获取资源的差距叫“”缺额“”。

调度器会优先为缺额大的作业分配资源。



 ### 1）FIFO策略

公平调度器每个队列资源分配策略如果选择FIFO的话。此时公平调度器相当于容量调度器。

 ### 2）FAIR策略

默认情况下，每个队列内部采用该方式分配资源，这就意味着，如果一个对列中有两个应用程序同时运行，则每个应用程序可得到1/2的资源；如果三个应用程序同时运行，则每个应用程序可得到1/3的资源。

## 4.例子

有一个队列总资源是12个，有4个job，对资源的需求分别是：

job->1   job2->2  job3->6  job4->5 

第一次算12/4=3

job1 分3 多(3-1=2)

job2 分3 多(3-2=1)

job3 分3 差6(6-3=3)

job4 分3 差2(5-3=2)

第二次算 （多出来的[2+1]）/(几个节点缺[2])=1.5

job1 分1

job2 分2

job3 分3+1.5(差6-4.5=1.5)

job4 分3+1.5(差5-4.5=0.5)

结束(分到没有空闲资源就结束了)

# 四、实际生产
```
<configuration>
  <property>
    <name>yarn.scheduler.capacity.maximum-applications</name>
    <value>10000</value>
    <description>
      可以挂起和运行的最大应用程序数.
    </description>
  </property>
 
  <property>
    <name>yarn.scheduler.capacity.maximum-am-resource-percent</name>
    <value>0.1</value>
    <description>
      集群中可用于运行应用程序主控的资源的最大百分比,即控制并发运行的应用程序的数量.
    </description>
  </property>
 
  <property>
    <name>yarn.scheduler.capacity.resource-calculator</name>
    <value>org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator</value>
    <description>
    用于比较调度程序中的资源的ResourceCalculator实现。
    默认即DefaultResourceCalculator仅使用Memory
    而DominantResourceCalculator使用显性资源来比较多维资源，例如 Memory、CPU 等。
    </description>
  </property>
 
<!-- 指定多队列,增加hive队列 -->
  <property>
    <name>yarn.scheduler.capacity.root.queues</name>
    <value>default,hive</value>
    <description>
      The queues at the this level (root is the root queue).
    </description>
  </property>
 
<!-- 指定各队列的资源额定容量 -->
  <property>
    <name>yarn.scheduler.capacity.root.default.capacity</name>
    <value>40</value>
    <description>Default queue target capacity.</description>
  </property>
  <property>
      <name>yarn.scheduler.capacity.root.hive.capacity</name>
      <value>60</value>
  </property>
 
<!-- 指定各队列的资源最大容量 -->
  <property>
    <name>yarn.scheduler.capacity.root.default.maximum-capacity</name>
    <value>60</value>
    <description>
      The maximum capacity of the default queue.
    </description>
  </property>
    <property>
      <name>yarn.scheduler.capacity.root.hive.maximum-capacity</name>
      <value>80</value>
  </property>
 
<!-- 用户最多可以使用队列多少资源,1表示所有.即root用户最多可以占用每个队列的所有资源-->
  <property>
    <name>yarn.scheduler.capacity.root.default.user-limit-factor</name>
    <value>1</value>
    <description>
      Default queue user limit a percentage from 0.0 to 1.0.
    </description>
  </property>
  <property>
      <name>yarn.scheduler.capacity.root.hive.user-limit-factor</name>
      <value>1</value>
  </property>
 
<!-- 启动两个队列 -->
  <property>
    <name>yarn.scheduler.capacity.root.default.state</name>
    <value>RUNNING</value>
    <description>
      The state of the default queue. State can be one of RUNNING or STOPPED.
    </description>
  </property>
  <property>
      <name>yarn.scheduler.capacity.root.hive.state</name>
      <value>RUNNING</value>
  </property>
 
<!-- 哪些用户有权向队列提交作业 -->
  <property>
    <name>yarn.scheduler.capacity.root.default.acl_submit_applications</name>
    <value>*</value>
    <description>
      The ACL of who can submit jobs to the default queue.
    </description>
  </property>
  <property>
      <name>yarn.scheduler.capacity.root.hive.acl_submit_applications</name>
      <value>*</value>
  </property>
 
<!-- 哪些用户有权操作队列，管理员权限（查看/杀死） -->
  <property>
    <name>yarn.scheduler.capacity.root.default.acl_administer_queue</name>
    <value>*</value>
    <description>
      The ACL of who can administer jobs on the default queue.
    </description>
  </property>
  <property>
      <name>yarn.scheduler.capacity.root.hive.acl_administer_queue</name>
      <value>*</value>
  </property>
 
<!-- 哪些用户有权配置提交任务优先级 -->
  <property>
    <name>yarn.scheduler.capacity.root.default.acl_application_max_priority</name>
    <value>*</value>
    <description>
    </description>
  </property>
  <property>
      <name>yarn.scheduler.capacity.root.hive.acl_application_max_priority</name>
      <value>*</value>
  </property>
 
 
<!-- 任务的超时时间设置：yarn application -appId appId -updateLifetime Timeout-->
<!-- 如果application指定了超时时间(-updateLifetime Timeout)，则提交到该队列的application能够指定的最大超时时间不能超过该值.-1表示不受限.-->
  <property>
      <name>yarn.scheduler.capacity.root.hive.maximum-application-lifetime</name>
      <value>-1</value>
  </property>
     <property>
     <name>yarn.scheduler.capacity.root.default.maximum-application-lifetime</name>
     <value>-1</value>
     <description>
     </description>
   </property>
 
<!-- 如果application没指定超时时间，则用default-application-lifetime作为默认值 -->
  <property>
    <name>yarn.scheduler.capacity.root.default.default-application-lifetime</name>
    <value>-1</value>
  </property>
  <property>
      <name>yarn.scheduler.capacity.root.hive.default-application-lifetime</name>
      <value>-1</value>
  </property>
 
 
 
  <property>
    <name>yarn.scheduler.capacity.node-locality-delay</name>
    <value>40</value>
    <description>
      Number of missed scheduling opportunities after which the CapacityScheduler
      attempts to schedule rack-local containers.
      When setting this parameter, the size of the cluster should be taken into account.
      We use 40 as the default value, which is approximately the number of nodes in one rack.
      Note, if this value is -1, the locality constraint in the container request
      will be ignored, which disables the delay scheduling.
    </description>
  </property>
 
  <property>
    <name>yarn.scheduler.capacity.rack-locality-additional-delay</name>
    <value>-1</value>
    <description>
      Number of additional missed scheduling opportunities over the node-locality-delay
      ones, after which the CapacityScheduler attempts to schedule off-switch containers,
      instead of rack-local ones.
      Example: with node-locality-delay=40 and rack-locality-delay=20, the scheduler will
      attempt rack-local assignments after 40 missed opportunities, and off-switch assignments
      after 40+20=60 missed opportunities.
      When setting this parameter, the size of the cluster should be taken into account.
      We use -1 as the default value, which disables this feature. In this case, the number
      of missed opportunities for assigning off-switch containers is calculated based on
      the number of containers and unique locations specified in the resource request,
      as well as the size of the cluster.
    </description>
  </property>
 
  <property>
    <name>yarn.scheduler.capacity.queue-mappings</name>
    <value></value>
    <description>
      A list of mappings that will be used to assign jobs to queues
      The syntax for this list is [u|g]:[name]:[queue_name][,next mapping]*
      Typically this list will be used to map users to queues,
      for example, u:%user:%user maps all users to queues with the same name
      as the user.
    </description>
  </property>
 
  <property>
    <name>yarn.scheduler.capacity.queue-mappings-override.enable</name>
    <value>false</value>
    <description>
      If a queue mapping is present, will it override the value specified
      by the user? This can be used by administrators to place jobs in queues
      that are different than the one specified by the user.
      The default is false.
    </description>
  </property>
 
  <property>
    <name>yarn.scheduler.capacity.per-node-heartbeat.maximum-offswitch-assignments</name>
    <value>1</value>
    <description>
      Controls the number of OFF_SWITCH assignments allowed
      during a node's heartbeat. Increasing this value can improve
      scheduling rate for OFF_SWITCH containers. Lower values reduce
      "clumping" of applications on particular nodes. The default is 1.
      Legal values are 1-MAX_INT. This config is refreshable.
    </description>
  </property>
 
 
  <property>
    <name>yarn.scheduler.capacity.application.fail-fast</name>
    <value>false</value>
    <description>
      Whether RM should fail during recovery if previous applications'
      queue is no longer valid.
    </description>
  </property>
</configuration>
```
