### 本通知适用的场景
---
&emsp;&emsp;巡检平台hls直播录制是否存在异常，包括以下情况：
- Sc中存在，se中不存在此直播；
- Se中存在，sc中不存在此直播；
- scse中直播分布不一致；
### 操作步骤
---
##### 主用sc上传两个脚本：
  - `sc_get_live_info.sh`
  - `se_get_live_info.sh`
##### 修改`sc_get_live_info.sh`如下配置用于节点内自动登陆：
```
########## Login parameter ############
user="ssh用户名"
passwd='ssh密码’
su_passwd='root密码'
port="ssh端口"
```
##### 执行脚本`sc_get_live_info.sh`,`sc_get_live_info.sh`会调用`se_get_live_info.sh`到各个se收集信息，并将信息传回给sc；
```
sh sc_get_live_info.sh
```
##### 执行结束后，会在本路径生成各se排查结果，类似下面：
![image](https://raw.githubusercontent.com/bluebell20/notification/master/screenshots/se_diff.png)
##### 查看各结果，若内容输出类似下图，则直播db正常，否则请联系片总处理：
```
head -100 *_diff.txt
```
![image](https://raw.githubusercontent.com/bluebell20/notification/master/screenshots/head_info.png)

