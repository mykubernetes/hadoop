NameNode在重启的时候，DataNode需要向NameNode发送块的信息，NameNode只有获取到整个文件系统中有99.9%（可以配置的）的块满足最小副本才会自动退出安全模式。最小副本和那个99.9%阀值可以通过下面配置来设定：
```
<property>
  <name>dfs.namenode.replication.min</name>
  <value>1</value>
  <description>Minimal block replication. 
  </description>
</property>
 
<property>
  <name>dfs.namenode.safemode.threshold-pct</name>
  <value>0.999f</value>
  <description>
    Specifies the percentage of blocks that should satisfy the minimal
    replication requirement defined by dfs.namenode.replication.min.
    Values less than or equal to 0 mean not to wait for any particular
    percentage of blocks before exiting safemode.
    Values greater than 1 will make safe mode permanent.
  </description>
</property>
```

　Hadoop中每个块的默认最小副本为1；dfs.namenode.safemode.threshold-pct参数的意思是指定达到最小副本数的数据块的百分比。这个值小等于0表示无须等待就可以退出安全模式；而如果这个值大于1表示永远处于安全模式。除了上面两个参数对安全模式有影响之外，下面几个参数也会对安全模式有影响
```
<property>
  <name>dfs.namenode.safemode.min.datanodes</name>
  <value>0</value>
  <description>
    Specifies the number of datanodes that must be considered alive
    before the name node exits safemode.
    Values less than or equal to 0 mean not to take the number of live
    datanodes into account when deciding whether to remain in safe mode
    during startup.
    Values greater than the number of datanodes in the cluster
    will make safe mode permanent.
  </description>
</property>
 
<property>
  <name>dfs.namenode.safemode.extension</name>
  <value>30000</value>
  <description>
    Determines extension of safe mode in milliseconds 
    after the threshold level is reached.
  </description>
</property>
```
dfs.namenode.safemode.min.datanodes的意思指namenode退出安全模式之前有效的（活着的）datanode的数量。这个值小等于0表示在退出安全模式之前无须考虑有效的datanode节点个数，值大于集群中datanode节点总数则表示永远处于安全模式；dfs.namenode.safemode.extension表示在满足dfs.namenode.safemode.threshold-pct值之后，NameNode还需要处于安全模式的时间（单位是秒）。


集群处于安全模式，不能执行重要操作（写操作）。集群启动完成后，自动退出安全模式。
```
bin/hdfs dfsadmin -safemode get （功能描述：查看安全模式状态）
bin/hdfs dfsadmin -safemode enter （功能描述：进入安全模式状态）
bin/hdfs dfsadmin -safemode leave（功能描述：离开安全模式状态）
bin/hdfs dfsadmin -safemode wait（功能描述：等待安全模式状态）
```
