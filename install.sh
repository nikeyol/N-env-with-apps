#!/usr/bin/env bash

# change time zone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai
rm /etc/yum.repos.d/CentOS-Base.repo
cp /vagrant/yum/*.* /etc/yum.repos.d/
mv /etc/yum.repos.d/CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo

yum install -y curl wget jq envsubst awk bash getent grep gunzip less openssl sed tar base64 basename cat dirname head id mkdir numfmt sort tee

echo 'set host name resolution'
cat >> /etc/hosts <<EOF
echo 'set host name resolution'
cat >> /etc/hosts <<EOF
172.17.10.202 node2
172.17.10.201 node1
EOF
EOF

cat /etc/hosts

echo 'set nameserver'
echo "nameserver 8.8.8.8">/etc/resolv.conf
cat /etc/resolv.conf

echo 'disable swap'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab




# copy certificate
mkdir /etc/ssl/nginx
cp /vagrant/certificate/* /etc/ssl/nginx

# install the ca certificate dependency
yum install ca-certificates

# install n+ repo
wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.4.repo
yum install -y nginx-plus
systemctl enable nginx.service
service nginx start


# install docker
DOCKER_VERSION=18.09
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce-${DOCKER_VERSION} docker-ce-cli-${DOCKER_VERSION} containerd.io
sudo systemctl enable docker
sudo systemctl start docker


# pull demo backend apps
docker network create internal
sudo docker run -dit -h mainapp --name=mainapp --net=internal -p 9801:80 nikeyol/mainapp:latest
sudo docker run -dit -h backend --name=backend --net=internal -p 9803:80 nikeyol/backend:latest
sudo docker run -dit -h app2 --name=app2 --net=internal -p 9804:80 nikeyol/app2:latest
sudo docker run -dit -h app3 --name=app3 --net=internal -p 9805:80 nikeyol/app3:latest
