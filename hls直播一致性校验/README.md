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
# 定义登录方式,1代表登陆方式都相同，2代表登陆方式不同启用单独的登陆文件
longin_mode=1

# longin_mode=1时使用：
user="ssh用户名"
passwd='ssh密码’
su_passwd='root密码'
port="ssh端口"

# longin_mode=2时使用，脚本同路径编写host_info.txt;格式如下
# location ip port user password su_password
# 例：1-0-0-0 1.1.1.1 49721 fonsview FonsView!23+ hello123
# 使用如下命令可以快速生成前两列
# cat /opt/fonsview/NE/ss/data/proc/mng/nics |grep SESH |while read line;do location=`echo $line |awk '{print $1}'` ip=`echo $line |awk '{print $3}'|awk -F '(' '{print $1}'`; echo $location $ip ;done > host_info.txt
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

### 注意：
---
##### 自动化脚本`sc_get_live_info.sh`只适用用于节点内ssh互通的节点；若不符合上述情况，请使用`sc_get_live_info_manual.sh`，会生成`${location}_sc_sort.txt`，然后将生成的对应服务器的文件，跟`se_get_live_info.sh`传到各个se服务器，手动执行，查看结果。
### 历史版本：
---
##### Version0.3: 增加登陆管理配置，用于节点内登陆方式不同的节点；
##### Version0.2: 对于登陆方式相同节点，增加expect一键巡检功能；
##### Version0.1：手动版本。