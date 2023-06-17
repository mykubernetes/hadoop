官方文档：https://hadoop.apache.org/docs/r2.7.4/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapredCommands.html

#所有mapreduce命令都由bin/mapred脚本调用。没有任何参数运行映射脚本会打印所有命令的描述。

用法： `mapred [--config confdir] [--loglevel loglevel] COMMAND`

#其中COMMAND是其中之一：
```
Bash
pipes       #运行一个管道的工作。
job         #操纵MapReduce作业
queue       #命令交互,查看作业队列信息
classpath   #打印所需的类路径获取Hadoop jar和所需的库。
historyserver   #将作业历史记录服务器作为独立守护进程运行
distcp <srcurl> <desturl>   #递归地复制文件或目录。
archive -archiveName NAME -p <parent path> <src>* <dest>   #创建一个hadoop存档。
hsadmin          #负责执行MapReduce hsadmin客户机JobHistoryServer行政命令。
```

job
```
$ mapred job  #用法：CLI <command> <args>

Bash
-submit <job-file>      #提交作业
-status <job-id>        #打印map并减少完成百分比和所有作业计数器。
-counter <job-id> <group-name> <counter-name>   #打印计数器值。
-kill <job-id>           #杀死job
-set-priority <job-id> <priority>    #更改作业的优先级。允许的优先级值为VERY_HIGH，HIGH，NORMAL，LOW，VERY_LOW
-events <job-id> <from-event-#> <#-of-events>   #打印给定范围的jobtracker收到的事件的详细信息。
-history <jobHistoryFile>      #打印作业详细信息
-list [all]                    #显示尚未完成的作业。 -list all全部显示所有作业。
-list-active-trackers          #
-list-blacklisted-trackers     #
-list-attempt-ids <job-id> <task-type> <task-state>   #
-kill-task <task-attempt-id>    #杀死任务。 杀死的任务不计入失败的尝试。
-fail-task <task-attempt-id>    #失败的任务.失败的任务会计入失败的尝试次数。
-logs <job-id> <task-attempt-id>
```

pipes
```
$ mapred pipes   #跟hadoop pipes一样

Bash
-input <path>         #输入目录
-output <path>        #输出目录
-jar <jar file>        #jar文件名
-inputformat <class>    #InputFormat类
-map <class>            #Java映射类
-partitioner <class>    #Java分区
-reduce <class>         #Java reduce类
-writer <class>         #Java RecordWriter
-program <executable>   #可执行URI
-reduces <num>          #reduces的数量
-lazyOutput <true/false>  #createOutputLazil
```

queue
```
$ mapred queue

Bash
-list   #获取系统中配置的作业队列列表。 以及与作业队列相关联的调度信息。
-info <job-queue-name> [-showJobs]   #显示特定作业队列的作业队列信息和关联的调度信息。 如果存在-showJobs选项，则显示提交到特定作业队列的作业列表。
-showacls        #显示当前用户允许的队列名称和关联的队列操作。 列表只包含用户可以访问的队列。
```

hsadmin
```
Bash
-refreshUserToGroupsMappings           #刷新用户到组的映射
-refreshSuperUserGroupsConfiguration   #刷新超级用户代理组映射
-refreshAdminAcls                      #刷新管理工作历史服务器的acls
-refreshLoadedJobCache                 #刷新作业历史记录服务器的作业缓存
-refreshJobRetentionSettings           #刷新工作历史期，工作clean设置
-refreshLogRetentionSettings           #刷新日志保留期和日志保留检查间隔
-getGroups [username]                  #获取用户所属的组
-help [cmd]                            #显示给定命令或所有命令的帮助，如果没有指定。
```
