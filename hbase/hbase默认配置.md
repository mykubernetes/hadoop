```
hbase.rootdir
这个目录是region server的共享目录，用来持久化HBase。URL需要是'完全正确'的，还要包含文件系统的scheme。例如，要表示hdfs中的'/hbase'目录，namenode 运行在namenode.example.org的9090端口。则需要设置为hdfs://namenode.example.org:9000/hbase。默认情况下HBase是写到/tmp的。不改这个配置，数据会在重启的时候丢失。

默认: file:///tmp/hbase-${user.name}/hbase

hbase.master.port
HBase的Master的端口.

默认: 60000

hbase.cluster.distributed
HBase的运行模式。false是单机模式，true是分布式模式。若为false,HBase和Zookeeper会运行在同一个JVM里面。

默认: false

hbase.tmp.dir
本地文件系统的临时文件夹。可以修改到一个更为持久的目录上。(/tmp会在重启时清除)

默认:${java.io.tmpdir}/hbase-${user.name}

hbase.local.dir
作为本地存储，位于本地文件系统的路径。

默认: ${hbase.tmp.dir}/local/

hbase.master.info.port
HBase Master web 界面端口. 设置为-1 意味着你不想让他运行。

默认: 60010

hbase.master.info.bindAddress
HBase Master web 界面绑定的端口

默认: 0.0.0.0

hbase.client.write.buffer
HTable客户端的写缓冲的默认大小。这个值越大，需要消耗的内存越大。因为缓冲在客户端和服务端都有实例，所以需要消耗客户端和服务端两个地方的内存。得到的好处是，可以减少RPC的次数。可以这样估算服务器端被占用的内存： hbase.client.write.buffer * hbase.regionserver.handler.count

默认: 2097152

hbase.regionserver.port
HBase RegionServer绑定的端口

默认: 60020

hbase.regionserver.info.port
HBase RegionServer web 界面绑定的端口 设置为 -1 意味这你不想与运行 RegionServer 界面.

默认: 60030

hbase.regionserver.info.port.auto
Master或RegionServer是否要动态搜一个可以用的端口来绑定界面。当hbase.regionserver.info.port已经被占用的时候，可以搜一个空闲的端口绑定。这个功能在测试的时候很有用。默认关闭。

默认: false

hbase.regionserver.info.bindAddress
HBase RegionServer web 界面的IP地址

默认: 0.0.0.0

hbase.regionserver.class
RegionServer 使用的接口。客户端打开代理来连接region server的时候会使用到。

默认: org.apache.hadoop.hbase.ipc.HRegionInterface

hbase.client.pause
通常的客户端暂停时间。最多的用法是客户端在重试前的等待时间。比如失败的get操作和region查询操作等都很可能用到。

默认: 1000

hbase.client.retries.number
最大重试次数。所有需重试操作的最大值。例如从root region服务器获取root region，Get单元值，行Update操作等等。这是最大重试错误的值。  默认: 10.

默认: 10

hbase.bulkload.retries.number
最大重试次数。 原子批加载尝试的迭代最大次数。 0 永不放弃。默认: 0.

默认: 0

 

hbase.client.scanner.caching
当调用Scanner的next方法，而值又不在缓存里的时候，从服务端一次获取的行数。越大的值意味着Scanner会快一些，但是会占用更多的内存。当缓冲被占满的时候，next方法调用会越来越慢。慢到一定程度，可能会导致超时。例如超过了hbase.regionserver.lease.period。

默认: 100

hbase.client.keyvalue.maxsize
一个KeyValue实例的最大size.这个是用来设置存储文件中的单个entry的大小上界。因为一个KeyValue是不能分割的，所以可以避免因为数据过大导致region不可分割。明智的做法是把它设为可以被最大region size整除的数。如果设置为0或者更小，就会禁用这个检查。默认10MB。

默认: 10485760

hbase.regionserver.lease.period
客户端租用HRegion server 期限，即超时阀值。单位是毫秒。默认情况下，客户端必须在这个时间内发一条信息，否则视为死掉。

默认: 60000

hbase.regionserver.handler.count
RegionServers受理的RPC Server实例数量。对于Master来说，这个属性是Master受理的handler数量

默认: 10

hbase.regionserver.msginterval
RegionServer 发消息给 Master 时间间隔，单位是毫秒

默认: 3000

hbase.regionserver.optionallogflushinterval
将Hlog同步到HDFS的间隔。如果Hlog没有积累到一定的数量，到了时间，也会触发同步。
默认是1秒，单位毫秒。

默认: 1000

hbase.regionserver.regionSplitLimit
region的数量到了这个值后就不会在分裂了。这不是一个region数量的硬性限制。但是起到了一定指导性的作用，到了这个值就该停止分裂了。默认是MAX_INT.就是说不阻止分裂。

默认: 2147483647

hbase.regionserver.logroll.period
提交commit log的间隔，不管有没有写足够的值。

默认: 3600000

hbase.regionserver.hlog.reader.impl
HLog file reader 的实现.

默认: org.apache.hadoop.hbase.regionserver.wal.SequenceFileLogReader

hbase.regionserver.hlog.writer.impl
HLog file writer 的实现.

默认: org.apache.hadoop.hbase.regionserver.wal.SequenceFileLogWriter

 

hbase.regionserver.nbreservationblocks
储备的内存block的数量(译者注:就像石油储备一样)。当发生out of memory 异常的时候，我们可以用这些内存在RegionServer停止之前做清理操作。

默认: 4

hbase.zookeeper.dns.interface
当使用DNS的时候，Zookeeper用来上报的IP地址的网络接口名字。

默认: default

hbase.zookeeper.dns.nameserver
当使用DNS的时候，Zookeepr使用的DNS的域名或者IP 地址，Zookeeper用它来确定和master用来进行通讯的域名.

默认: default

hbase.regionserver.dns.interface
当使用DNS的时候，RegionServer用来上报的IP地址的网络接口名字。

默认: default

hbase.regionserver.dns.nameserver
当使用DNS的时候，RegionServer使用的DNS的域名或者IP 地址，RegionServer用它来确定和master用来进行通讯的域名.

默认: default

hbase.master.dns.interface
当使用DNS的时候，Master用来上报的IP地址的网络接口名字。

默认: default

hbase.master.dns.nameserver
当使用DNS的时候，RegionServer使用的DNS的域名或者IP 地址，Master用它来确定用来进行通讯的域名.

默认: default

hbase.balancer.period
Master执行region balancer的间隔。

默认: 300000

hbase.regions.slop
当任一区域服务器有average + (average * slop)个分区，将会执行重新均衡。默认 20% slop .

默认:0.2

hbase.master.logcleaner.ttl
Hlog存在于.oldlogdir 文件夹的最长时间, 超过了就会被 Master 的线程清理掉.

默认: 600000

hbase.master.logcleaner.plugins
LogsCleaner服务会执行的一组LogCleanerDelegat。值用逗号间隔的文本表示。
这些WAL/HLog cleaners会按顺序调用。可以把先调用的放在前面。
你可以实现自己的LogCleanerDelegat，加到Classpath下，然后在这里写下类的全称。
一般都是加在默认值的前面。

默认: org.apache.hadoop.hbase.master.TimeToLiveLogCleaner

hbase.regionserver.global.memstore.upperLimit
单个region server的全部memtores的最大值。超过这个值，一个新的update操作会被挂起，
强制执行flush操作。

默认: 0.4

hbase.regionserver.global.memstore.lowerLimit
当强制执行flush操作的时候，当低于这个值的时候，flush会停止。
默认是堆大小的 35% . 
如果这个值和 hbase.regionserver.global.memstore.upperLimit 
相同就意味着当update操作因为内存限制被挂起时，
会尽量少的执行flush(译者注:一旦执行flush，值就会比下限要低，不再执行)

默认: 0.35

hbase.server.thread.wakefrequency
service工作的sleep间隔，单位毫秒。 可以作为service线程的sleep间隔，比如log roller.

默认: 10000

hbase.server.versionfile.writeattempts
退出前尝试写版本文件的次数。每次尝试由 hbase.server.thread.wakefrequency 毫秒数间隔。

默认: 3

hbase.hregion.memstore.flush.size
当memstore的大小超过这个值的时候，会flush到磁盘。这个值被一个线程每隔hbase.server.thread.wakefrequency检查一下。

默认:134217728

hbase.hregion.preclose.flush.size
当一个region中的memstore的大小大于这个值的时候，我们又触发了close.会先运行“pre-flush”操作，
清理这个需要关闭的memstore，然后将这个region下线。当一个region下线了，
我们无法再进行任何写操作。如果一个memstore很大的时候，flush操作会消耗很多时间。
"pre-flush"操作意味着在region下线之前，会先把memstore清空。这样在最终执行close操作的时候，
flush操作会很快。

默认: 5242880

hbase.hregion.memstore.block.multiplier
如果memstore有hbase.hregion.memstore.block.multiplier倍数的hbase.hregion.flush.size的大小，
就会阻塞update操作。
这是为了预防在update高峰期会导致的失控。如果不设上界，
flush的时候会花很长的时间来合并或者分割，
最坏的情况就是引发out of memory异常。
(译者注:内存操作的速度和磁盘不匹配，需要等一等。原文似乎有误)

默认: 2

hbase.hregion.memstore.mslab.enabled
体验特性：启用memStore分配本地缓冲区。
这个特性是为了防止在大量写负载的时候堆的碎片过多。
这可以减少GC操作的频率。
(GC有可能会Stop the world)(译者注：实现的原理相当于预分配内存，而不是每一个值都要从堆里分配)

默认: true

hbase.hregion.max.filesize
最大HStoreFile大小。若某个列族的HStoreFile增长达到这个值，这个Hegion会被切割成两个。 
默认: 10G.

默认:10737418240

hbase.hstore.compactionThreshold
当一个HStore含有多于这个值的HStoreFiles(每一个memstore flush产生一个HStoreFile)的时候，
会执行一个合并操作，把这HStoreFiles写成一个。这个值越大，需要合并的时间就越长。

默认: 3

hbase.hstore.blockingStoreFiles
当一个HStore含有多于这个值的HStoreFiles(每一个memstore flush产生一个HStoreFile)的时候，
会执行一个合并操作，update会阻塞直到合并完成，直到超过了hbase.hstore.blockingWaitTime的值

默认: 7

hbase.hstore.blockingWaitTime
hbase.hstore.blockingStoreFiles所限制的StoreFile数量会导致update阻塞，这个时间是来限制阻塞时间的。当超过了这个时间，HRegion会停止阻塞update操作，不过合并还有没有完成。默认为90s.

默认: 90000

hbase.hstore.compaction.max
每个“小”合并的HStoreFiles最大数量。

默认: 10

hbase.hregion.majorcompaction
一个Region中的所有HStoreFile的major compactions的时间间隔。默认是1天。 设置为0就是禁用这个功能。

默认: 86400000

hbase.storescanner.parallel.seek.enable
允许 StoreFileScanner 并行搜索 StoreScanner, 一个在特定条件下降低延迟的特性。

默认: false

hbase.storescanner.parallel.seek.threads
并行搜索特性打开后，默认线程池大小。

默认: 10

 

hbase.mapreduce.hfileoutputformat.blocksize
MapReduce中HFileOutputFormat可以写 storefiles/hfiles. 这个值是hfile的blocksize的最小值。通常在HBase写Hfile的时候，bloocksize是由table schema(HColumnDescriptor)决定的，但是在mapreduce写的时候，我们无法获取schema中blocksize。这个值越小，你的索引就越大，你随机访问需要获取的数据就越小。如果你的cell都很小，而且你需要更快的随机访问，可以把这个值调低。

默认: 65536

hfile.block.cache.size
分配给HFile/StoreFile的block cache占最大堆(-Xmx setting)的比例。默认0.25意思是分配25%，设置为0就是禁用，但不推荐。

默认:0.25

hbase.hash.type
哈希函数使用的哈希算法。可以选择两个值:: murmur (MurmurHash) 和 jenkins (JenkinsHash). 
这个哈希是给 bloom filters用的.

默认: murmur

hfile.block.index.cacheonwrite
这允许在写入索引时将非根多级索引块写入到块缓存。

默认: false

hfile.index.block.max.size
当多层次块索引中的叶级、中间层或根级索引块的大小增长到这个大小时，该块将被写入，并开始一个新的块。

默认: 131072

hfile.format.version
新文件使用的HFile格式版本。设置为1来测试向后兼容性。此选项的默认值应符合FixedFileTrailer.MAX_VERSION.

默认: 2

io.storefile.bloom.block.size
复合Bloom滤波器的单个块（“chunk”）的字节大小。这个大小是近似的，因为Bloom块只能在数据块边界中插入，并且每个数据块的键数是不同的。

默认: 131072

hfile.block.bloom.cacheonwrite
允许对复合布鲁姆过滤器的内联块写缓存.

默认: false

hbase.rs.cacheblocksonwrite
块结束时,是否 HFile块应添加块缓存。

默认: false

hbase.rpc.server.engine
用于服务器的RPC调用编组的org.apache.hadoop.hbase.ipc.RpcServerEngine 实现.

默认: org.apache.hadoop.hbase.ipc.ProtobufRpcServerEngine

hbase.ipc.client.tcpnodelay
设置RPC套接字连接不延迟。参考 http://docs.oracle.com/javase/1.5.0/docs/api/java/net/Socket.html#getTcpNoDelay()

默认: true

hbase.master.keytab.file
HMaster server验证登录使用的kerberos keytab 文件路径。(译者注：HBase使用Kerberos实现安全)

默认:

hbase.master.kerberos.principal
例如. "hbase/_HOST@EXAMPLE.COM". HMaster运行需要使用 kerberos principal name. principal name 可以在: user/hostname@DOMAIN 中获取. 如果 "_HOST" 被用做hostname portion，需要使用实际运行的hostname来替代它。

默认:

hbase.regionserver.keytab.file
HRegionServer验证登录使用的kerberos keytab 文件路径。

默认:

hbase.regionserver.kerberos.principal
例如. "hbase/_HOST@EXAMPLE.COM". HRegionServer运行需要使用 kerberos principal name. principal name 可以在: user/hostname@DOMAIN 中获取. 如果 "_HOST" 被用做hostname portion，需要使用实际运行的hostname来替代它。在这个文件中必须要有一个entry来描述 hbase.regionserver.keytab.file

默认:

hadoop.policy.file
RPC服务器使用策略配置文件对客户端请求做出授权决策。仅当HBase启用了安全设置可用.

默认: hbase-policy.xml

hbase.superuser
拥有完整的特权用户或组的列表(逗号分隔), 不限于本地存储的 ACLs, 或整个集群. 仅当HBase启用了安全设置可用.

默认:

hbase.auth.key.update.interval
The update interval for master key for authentication tokens in servers in milliseconds. Only used when HBase security is enabled.

默认: 86400000

hbase.auth.token.max.lifetime
The maximum lifetime in milliseconds after which an authentication token expires. Only used when HBase security is enabled.

默认: 604800000

zookeeper.session.timeout
ZooKeeper 会话超时.HBase把这个值传递改zk集群，向他推荐一个会话的最大超时时间。详见http://hadoop.apache.org/zookeeper/docs/current/zookeeperProgrammers.html#ch_zkSessions "客户端发送请求超时，服务器响应它可以给客户端的超时"。 单位是毫秒

默认: 180000

zookeeper.znode.parent
ZooKeeper中的HBase的根ZNode。所有的HBase的ZooKeeper会用这个目录配置相对路径。默认情况下，所有的HBase的ZooKeeper文件路径是用相对路径，所以他们会都去这个目录下面。

默认: /hbase

zookeeper.znode.rootserver
ZNode 保存的 根region的路径. 这个值是由Master来写，client和regionserver 来读的。如果设为一个相对地址，父目录就是 ${zookeeper.znode.parent}.默认情形下，意味着根region的路径存储在/hbase/root-region-server.

默认: root-region-server

zookeeper.znode.acl.parent
Root ZNode for access control lists.

默认: acl

hbase.coprocessor.region.classes
一个逗号分隔的协处理器，通过在所有表的默认加载列表。对于任何重写协处理器方法，这些类将按顺序调用。实现你自己的协处理器后，就把它放在HBase的路径，在此添加完全限定名称。协处理器也可以装上设置HTableDescriptor需求。

默认:

hbase.coprocessor.master.classes
一个逗号分隔的org.apache.hadoop.hbase.coprocessor.MasterObserver 微处理器列表，主HMaster进程默认加载。对于任何实现的协处理器方法，列出的类将按顺序调用。实现你自己的MasterObserver后，就把它放在HBase的路径，在此处添加完全限定名称（fully qualified class name）。

默认:

hbase.zookeeper.quorum
Zookeeper集群的地址列表，用逗号分割。例如："host1.mydomain.com,host2.mydomain.com,host3.mydomain.com".默认是localhost,是给伪分布式用的。要修改才能在完全分布式的情况下使用。如果在hbase-env.sh设置了HBASE_MANAGES_ZK，这些ZooKeeper节点就会和HBase一起启动。

默认: localhost

hbase.zookeeper.peerport
ZooKeeper节点使用的端口。详细参见：http://hadoop.apache.org/zookeeper/docs/r3.1.1/zookeeperStarted.html#sc_RunningReplicatedZooKeeper

默认: 2888

hbase.zookeeper.leaderport
ZooKeeper用来选择Leader的端口，详细参见：http://hadoop.apache.org/zookeeper/docs/r3.1.1/zookeeperStarted.html#sc_RunningReplicatedZooKeeper

默认: 3888

hbase.zookeeper.useMulti
指示HBase使用ZooKeeper的多更新功能。这让某些管理员操作完成更迅速，防止一些问题与罕见的复制失败的情况下（见例hbase-2611版本说明）。重要的是：只有设置为true，如果集群中的所有服务器上的管理员3.4版本不会被降级。ZooKeeper管理员3.4之前的版本不支持多更新不优雅地失败如果多更新时把它放在HBase的路径，在这里添加完全限定名称。 (参考 ZOOKEEPER-1495).

默认: false

hbase.zookeeper.property.initLimit
ZooKeeper的zoo.conf中的配置。 初始化synchronization阶段的ticks数量限制

默认: 10

hbase.zookeeper.property.syncLimit
ZooKeeper的zoo.conf中的配置。 发送一个请求到获得承认之间的ticks的数量限制

默认: 5

hbase.zookeeper.property.dataDir
ZooKeeper的zoo.conf中的配置。 快照的存储位置

默认: ${hbase.tmp.dir}/zookeeper

hbase.zookeeper.property.clientPort
ZooKeeper的zoo.conf中的配置。 客户端连接的端口

默认: 2181

hbase.zookeeper.property.maxClientCnxns
ZooKeeper的zoo.conf中的配置。 ZooKeeper集群中的单个节点接受的单个Client(以IP区分)的请求的并发数。这个值可以调高一点，防止在单机和伪分布式模式中出问题。

默认: 300

hbase.rest.port
HBase REST server的端口

默认: 8080

hbase.rest.readonly
定义REST server的运行模式。可以设置成如下的值： false: 所有的HTTP请求都是被允许的 - GET/PUT/POST/DELETE. true:只有GET请求是被允许的

默认: false

hbase.defaults.for.version.skip
设置为true，跳过 'hbase.defaults.for.version' 检查。 设置为 true 相对maven 生成很有用，例如ide环境. 你需要将该布尔值设为 true，避免看到RuntimException 抱怨: "hbase-default.xml file seems to be for and old version of HBase (\${hbase.version}), this version is X.X.X-SNAPSHOT"

默认: false

hbase.coprocessor.abortonerror
Set to true to cause the hosting server (master or regionserver) to abort if a coprocessor throws a Throwable object that is not IOException or a subclass of IOException. Setting it to true might be useful in development environments where one wants to terminate the server as soon as possible to simplify coprocessor failure analysis.

默认: false

hbase.online.schema.update.enable
Set true to enable online schema changes. This is an experimental feature. There are known issues modifying table schemas at the same time a region split is happening so your table needs to be quiescent or else you have to be running with splits disabled.

默认: false

hbase.table.lock.enable
Set to true to enable locking the table in zookeeper for schema change operations. Table locking from master prevents concurrent schema modifications to corrupt table state.

默认: true

dfs.support.append
Does HDFS allow appends to files? This is an hdfs config. set in here so the hdfs client will do append support. You must ensure that this config. is true serverside too when running hbase (You will have to restart your cluster after setting it).

默认: true

hbase.thrift.minWorkerThreads
The "core size" of the thread pool. New threads are created on every connection until this many threads are created.

默认: 16

hbase.thrift.maxWorkerThreads
The maximum size of the thread pool. When the pending request queue overflows, new threads are created until their number reaches this number. After that, the server starts dropping connections.

默认: 1000

hbase.thrift.maxQueuedRequests
The maximum number of pending Thrift connections waiting in the queue. If there are no idle threads in the pool, the server queues requests. Only when the queue overflows, new threads are added, up to hbase.thrift.maxQueuedRequests threads.

默认: 1000

hbase.offheapcache.percentage
The amount of off heap space to be allocated towards the experimental off heap cache. If you desire the cache to be disabled, simply set this value to 0.

默认: 0

hbase.data.umask.enable
Enable, if true, that file permissions should be assigned to the files written by the regionserver

默认: false

hbase.data.umask
hbase.data.umask.enable为真时，用于写数据文件文件的权限

默认: 000

hbase.metrics.showTableName
Whether to include the prefix "tbl.tablename" in per-column family metrics. If true, for each metric M, per-cf metrics will be reported for tbl.T.cf.CF.M, if false, per-cf metrics will be aggregated by column-family across tables, and reported for cf.CF.M. In both cases, the aggregated metric M across tables and cfs will be reported.

默认: true

hbase.metrics.exposeOperationTimes
是否报告有关在区域服务器上执行操作的时间的度量。 Get, Put, Delete, Increment, 及 Append 都可以有他们的时间，每CF和每个区域都可以通过Hadoop metrics暴露出来。

默认: true

hbase.master.hfilecleaner.plugins
一个以逗号分隔的HFileCleanerDelegate HFileCleaner调用的服务。这些HFile清除服务被按顺序调用,所以把清除大部分文件的清除服务放在最前面。实现自己的HFileCleanerDelegate,需把它放在HBase的类路径,并在此添加完全限定类名。总是添加上述日志清除服务，因为会被hbase-site.xml的配置覆盖。

默认: org.apache.hadoop.hbase.master.cleaner.TimeToLiveHFileCleaner

hbase.regionserver.catalog.timeout
Catalog Janitor从regionserver到 META的超时值.

默认: 600000

hbase.master.catalog.timeout
Catalog Janitor从master到 META的超时值.

默认: 600000

hbase.config.read.zookeeper.config
设置为true，允许HBaseConfiguration读取 zoo.cfg 文件，获取ZooKeeper配置。切换为true是不推荐的，因为从zoo.cfg文件读取ZK配置功能已废弃。

默认: false

hbase.snapshot.enabled
设置为true允许快照被取/恢复/克隆。

默认: true

hbase.rest.threads.max
REST服务器线程池的最大线程数。池中的线程被重用以处理REST请求。该值控制同时处理的最大请求数。这可能有助于控制REST服务器内存，避免OOM问题。如果线程池已满，传入的请求将被排队等待一些空闲线程。默认值是100.

默认: 100

hbase.rest.threads.min
REST服务器线程池的最小线程数。线程池始终具有该数量的线程，以便REST服务器准备好为传入的请求服务。默认值是 2.

默认: 2
```
