#!/bin/bash
yum install gcc gcc-c++  -y
mkdir -p /source
cd /source
wget http://www.zlib.net/fossils/zlib-1.2.11.tar.gz
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.3p1.tar.gz
wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1g.tar.gz

tar --no-same-owner -zxvf zlib-1.2.11.tar.gz
tar --no-same-owner -zxvf openssh-8.3p1.tar.gz
tar --no-same-owner -zxvf openssl-1.1.1g.tar.gz

#编译安装zlib-1.2.11
cd zlib-1.2.11
./configure --prefix=/usr/local/zlib
make && make install

#编译安装openssl-1.1.1g
cd ../openssl-1.1.1g
./config --prefix=/usr/local/ssl -d shared
make && make install
echo '/usr/local/ssl/lib' >> /etc/ld.so.conf
ldconfig -v

#编译安装openssh-8.3p1
cd ../openssh-8.3p1
./configure --prefix=/usr/local/openssh --with-zlib=/usr/local/zlib --with-ssl-dir=/usr/local/ssl
make && make install

#备份修改配置文件
echo 'PermitRootLogin yes' >>/usr/local/openssh/etc/sshd_config
echo 'PubkeyAuthentication yes' >>/usr/local/openssh/etc/sshd_config
echo 'PasswordAuthentication yes' >>/usr/local/openssh/etc/sshd_config
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cp /usr/local/openssh/etc/sshd_config /etc/ssh/sshd_config
mv /usr/sbin/sshd /usr/sbin/sshd.bak
cp /usr/local/openssh/sbin/sshd /usr/sbin/sshd
mv /usr/bin/ssh /usr/bin/ssh.bak
cp /usr/local/openssh/bin/ssh /usr/bin/ssh
mv /usr/bin/ssh-keygen /usr/bin/ssh-keygen.bak
cp /usr/local/openssh/bin/ssh-keygen /usr/bin/ssh-keygen
mv /etc/ssh/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub.bak
cp /usr/local/openssh/etc/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub

#拷贝启动脚本并启动sshd
cp ./contrib/redhat/sshd.init /etc/init.d/
cd /etc/init.d/
sh sshd.init start