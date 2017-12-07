#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
rm -rf ssr.sh*
#定义变量
IPAddress=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
web="https://"; 
ServerLocation='Download';
#测试线路
clear
GIT='raw.githubusercontent.com'
MY='gitee.com'
GIT_PING=`ping -c 1 -w 1 $GIT|grep time=|awk '{print $7}'|sed "s/time=//"`
MY_PING=`ping -c 1 -w 1 $MY|grep time=|awk '{print $7}'|sed "s/time=//"`
echo "$GIT_PING $GIT" > ping.pl
echo "$MY_PING $MY" >> ping.pl
MirrorHost=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
if [ "$MirrorHost" == "$GIT" ];then
	MirrorHost='raw.githubusercontent.com/echo-marisn/ssv2/master'
	echo '检测你的服务器更适合github.com，已选择GitHub资源'
	sleep 3
else
	MirrorHost='gitee.com/marisn/ssv2/raw/master'
	echo '检测你的服务器更适合gitee.com，已选择Gitee资源'
	sleep 3
fi
rm -f ping.pl
#设置
function Settings(){
read -p "请输入数据库密码(默认root)： " mysqlpass
if [ -z $mysqlpass ]
then
echo  "数据库密码：root"
mysqlpass=root
else
echo "数据库密码：$mysqlpass"
fi
read -p "请输入后台登陆账号，请使用邮箱方式(默认marisn@67cc.cn)： " User
if [ -z $User ]
then
echo  "后台账号：marisn@67cc.cn"
User=marisn@67cc.cn
else
echo "后台账号：$User"
fi
read -p "请输入后台登陆密码(默认marisn)： " Pass
if [ -z $Pass ]
then
echo  "后台账号：marisn"
Pass=marisn
else
echo "后台账号：$User"
fi
read -p "请输入SS连接端口(默认8080)： " Port
if [ -z $Port ]
then
echo  "SS连接端口：8080"
Port=8080
else
echo "SS连接端口：$Port"
fi
read -p "请输入SS连接密码密码，(默认marisn)： " sspass
if [ -z $sspass ]
then
echo  "SS连接密码：marisn"
sspass=marisn
else
echo "SS连接密码：$sspass"
fi
}
#检查系统
function install_sspanel(){
yum -y install redhat-lsb* zip unzip 
File="/usr/bin/lsb_release"
if [ ! -f "$File" ]; then  
yum install lsb -y
fi
version=`lsb_release -a | grep -e Release|awk -F ":" '{ print $2 }'|awk -F "." '{ print $1 }'`
if [ $version == "6" ];then
rpm -ivh ${web}${MirrorHost}/${ServerLocation}/epel-release-6-8.noarch.rpm  >/dev/null 2>&1
rpm -ivh ${web}${MirrorHost}/${ServerLocation}/remi-release-6.rpm  >/dev/null 2>&1
fi
if [ $version == "7" ];then
echo 
    echo "安装被终止，请在Centos6系统上执行操作..."
    exit
fi
if [ ! $version ];then
    echo 
    echo "安装被终止，请在Centos系统上执行操作..."
	exit
fi
clear 
#lamp
echo "开始安装LAMP环境" 
yum -y install httpd 
chkconfig httpd on
/etc/init.d/httpd start
yum remove -y mysql*
yum --enablerepo=remi install -y mysql mysql-server mysql-devel
chkconfig mysqld on 
service mysqld start
yum remove -y php*
yum install -y --enablerepo=remi --enablerepo=remi-php56 php php-opcache php-devel php-mbstring php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-bcmath php-cli php-common  php-devel php-fpm    php-gd php-imap  php-ldap php-mysql  php-odbc  php-pdo  php-pear  php-pecl-igbinary  php-xml php-xmlrpc php-opcache php-intl php-pecl-memcache
service php-fpm start
service httpd restart
cd /var/www/html
wget ${web}${MirrorHost}/${ServerLocation}/phpmyadmin.zip  
unzip phpmyadmin.zip   
rm -f phpmyadmin.zip
service php-fpm restart
service httpd restart
service mysqld restart
rm -rf /bin/lamp
echo "#!/bin/sh
echo 正在重启lamp服务...
service mysqld restart 
service php-fpm restart 
service httpd restart
echo 服务已启动
exit 0;
" >/bin/lamp
chmod 0777 /bin/lamp
#自动选择下载节点
GIT='raw.githubusercontent.com'
LIB='download.libsodium.org'
GIT_PING=`ping -c 1 -w 1 $GIT|grep time=|awk '{print $7}'|sed "s/time=//"`
LIB_PING=`ping -c 1 -w 1 $LIB|grep time=|awk '{print $7}'|sed "s/time=//"`
echo "$GIT_PING $GIT" > ping.pl
echo "$LIB_PING $LIB" >> ping.pl
libAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
if [ "$libAddr" == "$GIT" ];then
	libAddr='https://raw.githubusercontent.com/echo-marisn/ssrv3-one-click-script/master/libsodium-1.0.13.tar.gz'
else
	libAddr='https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz'
fi
rm -f ping.pl
wget --no-check-certificate $libAddr
tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
./configure && make -j2 && make install
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig
#安装ss
yum -y install m2crypto python-setuptools
easy_install pip
pip install cymysql
cd /root
git clone -b manyuser https://github.com/shadowsocksrr/shadowsocksr.git "/root/shadowsocks"
cd /root/shadowsocks
yum -y install lsof lrzsz
yum -y install python-devel
yum -y install libffi-devel
yum -y install openssl-devel
pip install -r requirements.txt
cp apiconfig.py userapiconfig.py
cp config.json user-config.json
sed -i "4s/ss/root/" /root/shadowsocks/usermysql.json  
sed -i "5s/pass/$mysqlpass/" /root/shadowsocks/usermysql.json  
sed -i "6s/sspanel/shadowsocks/" /root/shadowsocks/usermysql.json  
sed -i "7s/0/1/" /root/shadowsocks/usermysql.json  
cd /root
mysqladmin -u root password $mysqlpass 
mysql -uroot -p$mysqlpass -e"CREATE DATABASE shadowsocks;" 
cd /var/www/html
wget ${web}${MirrorHost}/${ServerLocation}/ss.zip  
unzip ss.zip  
rm -rf ss.zip
cd lib/
cp config-simple.php config.php
password=`echo -n $Pass|md5sum|awk '{print $1}'|sed "s/  -//"`
sed -i "16s/password/$mysqlpass/" /var/www/html/lib/config.php  
sed -i "33s/first@blood.com/$User/" /var/www/html/sql/user.sql
sed -i "33s/LoveFish/$sspass/" /var/www/html/sql/user.sql
sed -i "33s/c5a4e7e6882845ea7bb4d9462868219b/$password/" /var/www/html/sql/user.sql
sed -i "33s/10000/$Port/" /var/www/html/sql/user.sql
cd /var/www/html/sql
mysql -uroot -p$mysqlpass shadowsocks < invite_code.sql
mysql -uroot -p$mysqlpass shadowsocks < ss_node.sql
mysql -uroot -p$mysqlpass shadowsocks < ss_reset_pwd.sql
mysql -uroot -p$mysqlpass shadowsocks < ss_user_admin.sql
mysql -uroot -p$mysqlpass shadowsocks < user.sql
echo "正在启动SSR服务" 
sleep 1
cd /root/shadowsocks
chmod +x *.sh
./logrun.sh
chmod +x /etc/rc.d/rc.local
echo "/root/shadowsocks/run.sh" >/etc/rc.d/rc.local
rm -rf /bin/SSR
echo "#!/bin/sh
echo 正在重启SSR服务...
/root/shadowsocks/stop.sh
/root/shadowsocks/run.sh
echo 服务已启动
exit 0;
" >/bin/SSR
chmod 0777 /bin/SSR
echo "配置网络环境..."
#iptables
iptables -F
service iptables save
service iptables restart
iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
service iptables save
service iptables stop
chkconfig iptables off
}
function install_success(){
echo 恭喜！您的SSR服务已启动
echo
echo 恭喜您搭建成功！
echo
echo 数据库地址：http://$IPAddress/phpmyadmin
echo
echo 用户地址：http://$IPAddress/
echo
echo 管理后台：http://$IPAddress/admin
echo 
echo 你的数据库账号：root
echo
echo 你的数据库密码：$mysqlpass
echo 
echo 你的后台账号：$User
echo
echo 你的后台密码：$Pass
echo
echo 连接端口：$Port
echo
echo 连接密码：$sspass
echo
echo 本地端口：1080
echo
echo 加密方式：aes-256-cfb
echo
echo 协议：auth_sha1
echo
echo 混淆方式：http_simple
echo
echo lamp快捷重启命令：lamp
echo 
echo SSR快捷重启命令：SSR
echo 
echo 您的IP是：$IPAddress 
}
Settings
install_sspanel
install_success