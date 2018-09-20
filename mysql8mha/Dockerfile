FROM centos
MAINTAINER kerrigell@gmail.com
ENV PERCONA_VERSION 5.7.23-23
ENV MYSQL_PORT 3306
ENV PERCONA_FILE 57-${PERCONA_VERSION}.1.el7
ENV PERCONA_DOWN_PATH https://www.percona.com/downloads/Percona-Server-LATEST/Percona-Server-${PERCONA_VERSION}/binary/redhat/7/x86_64
ENV MHA_DOWN_PATH https://downloads.mariadb.com/MHA
#### SERVER ROLE ####
## MYSQLM MYSQLS MHAM ##
ENV ROLE MYSQLM
#### SERVER ROLE ####
RUN rm -rf /etc/yum.repos.d/* && \
	curl http://mirrors.aliyun.com/repo/Centos-7.repo -o /etc/yum.repos.d/CentOS-Base.repo && \
	sed -i '/aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
	curl http://mirrors.aliyun.com/repo/epel-7.repo -o /etc/yum.repos.d/aliepel-7.repo && \
	sed -i '/aliyuncs.com/d'  /etc/yum.repos.d/aliepel-7.repo && \
	yum clean all && \
	mkdir -p /root/.ssh && mkdir -p /work/depot && \
	mkdir -p /etc/mysql && \
	mkdir -p /etc/masterha /var/log/masterha

RUN yum install -y perl net-tools \
		perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Module-Install \
		perl-Data-Dumper \
		libaio numactl \
		openssh-server openssh-clients \
		supervisor \
        wget
		
VOLUME ["/data/"]
WORKDIR /work/depot

# install mha
RUN cd /work/depot && \
    wget -nv ${MHA_DOWN_PATH}/mha4mysql-manager-0.56.tar.gz  && \
    wget -nv ${MHA_DOWN_PATH}/mha4mysql-node-0.56.tar.gz && \
    tar zxvf mha4mysql-manager-0.56.tar.gz && \
    tar zxvf mha4mysql-node-0.56.tar.gz && \
    cd /work/depot/mha4mysql-node-0.56 && perl Makefile.PL  && make && make install  && \
    cd /work/depot/mha4mysql-manager-0.56 && perl Makefile.PL  && make && make install

# install percona MySQL
RUN cd /work/depot && \
    wget -nv ${PERCONA_DOWN_PATH}/Percona-Server-client-${PERCONA_FILE}.x86_64.rpm  && \
    wget -nv ${PERCONA_DOWN_PATH}/Percona-Server-devel-${PERCONA_FILE}.x86_64.rpm   && \
    wget -nv ${PERCONA_DOWN_PATH}/Percona-Server-server-${PERCONA_FILE}.x86_64.rpm  && \
    wget -nv ${PERCONA_DOWN_PATH}/Percona-Server-shared-${PERCONA_FILE}.x86_64.rpm  && \
    wget -nv ${PERCONA_DOWN_PATH}/Percona-Server-shared-compat-${PERCONA_FILE}.x86_64.rpm  && \
    yum remove -y  mariadb-libs && \
    rpm -ivh Percona-Server-*.rpm

# config system
RUN groupadd mysql || useradd -m -g mysql  mysql  || echo "ok" && \
	rm -rf /var/lib/mysql/* && \
	rm -rf /work/depot/* && \
	yum clean all && \
	mkdir -p /home/mysql/.ssh && \
	echo "prepare ssh key" && \
	cd /root/.ssh/ && ssh-keygen -q -N "" -t rsa -f id_rsa && cp id_rsa.pub authorized_keys && \
	cd /home/mysql/.ssh && ssh-keygen -q -N "" -t rsa -f id_rsa && cp id_rsa.pub authorized_keys && \
	sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd && \
	chmod 700 /root/.ssh && chmod 600 /root/.ssh/* && \
	chown -R mysql:mysql /home/mysql && chmod 700 /home/mysql/.ssh && chmod 600 /home/mysql/.ssh/*

ADD my.cnf /etc/mysql/my.tpl
ADD init.sh /tmp/
ADD supervisord.conf /etc/supervisord.conf
ADD mhaapp.cnf /etc/masterha/mhaapp.tpl
EXPOSE 3306 22

##### Clean

#ENTRYPOINT ["bash", "/tmp/init.sh"]
CMD ["bash","/tmp/init.sh"]

##### CPAN:set auto install 
# RUN export PERL_MM_USE_DEFAULT=1
# RUN yum install -y cpan make gcc
# RUN cpan DBI DBD::mysql Config::Tiny Log::Dispatch Parallel::ForkManager 
##### CPAN

