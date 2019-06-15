获取ganglia的gmetad的指标数据脚本
===

在远端收集metad数据需要配置  
```
# vim /etc/ganglia/metad.conf
trusted_hosts 127.0.0.1 192.168.101.68
```  

脚本使用方法  
```
# python check_ganglia_metric.py -h node02 -m disk_free -w 100 -c 80
CHECKGANGLIA CRITICAL: disk_free is 16.90
```  
