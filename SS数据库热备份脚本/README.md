### 本通知适用的场景
---
&emsp;&emsp;用于现网SS网元DB定期热备份。
### 操作步骤
---
##### 1. 脚本上传至各节点主备SC服务器任意目录执行。

##### 2. 生成计划任务：会在本服务器`/opt/fonsview/bin`目录生成`ss_DB_hotbackup.sh`脚本、`/etc/cron.d/`目录生成`ss_DB_hotbackup.cron`计划任务文件。每天在备用SC定时备份SS数据库；主用SC定时备份点播与直播清单。

```bash
sh ss_DB_hotbackup.sh -c
```
##### 3. 停止计划任务：删除计划任务与DB备份脚本。
```bash
sh ss_DB_hotbackup.sh -k
```
### 版本历史：
---
Version 0.2：因部分现场发现备份时SS DB状态存在异常；去除主用SC定时备份db功能；

Version 0.1：原始版本。