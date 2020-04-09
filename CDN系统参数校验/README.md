### 本通知适用的场景
---
&emsp;&emsp;未执行过此脚本的ss服务器，可使用此脚本对内核进行优化；因现场环境各异，内核参数不尽相同。通过此脚本对各现场参数进行统一。
### 操作步骤
---
##### 脚本上传至ss服务器执行，当发现与建议值不符，脚本发出询问是否修改；若修改输入y 或yes确认；若不修改输入n或no取消。
```
sh modifie_kernel_para.sh
```
##### 例如：
![image](https://raw.githubusercontent.com/bluebell20/notification/master/screenshots/kernel_p.png)
##### 执行脚本后若发现异常回退步骤如下，此处以centos7为例；
```
cd /root
cp 20-nproc.conf.bak /etc/security/limits.d/20-nproc.conf  #不同操作系统此文件名不同
cp sysctl.conf.bak /etc/sysctl.conf
sysctl -p
```
### 版本历史：
---
Version 0.4: 当脚本询问是否执行时，键盘输入错误无法删除的问题；  
Version 0.3：屏幕打印增加当前值与建议值比较；  
Version 0.2：解决net.netfilter.nf_conntrack_buckets无法修改的问题；  
Version 0.1：第一版。