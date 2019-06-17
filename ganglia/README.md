获取ganglia的gmetad的指标数据脚本
===

在远端收集metad数据需要配置  
```
# vim /etc/ganglia/metad.conf
trusted_hosts 127.0.0.1 192.168.101.68
```  

脚本使用方法  
```
# python check_ganglia_metric.py -h node02 -m disk_free -w 80 -c 100
CHECKGANGLIA OK: disk_free is 16.90
```  

```
# php check_ganglia_metric.php node02 crond notequal 1
crond OK - Value = 1 status
```  
