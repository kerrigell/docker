FROM centos
MAINTAINER kerrigell@gmail.com
#ENV http_proxy 10.199.75.12:8080
RUN rm -rf /etc/yum.repos.d/* && \
	 curl http://mirrors.aliyun.com/repo/Centos-7.repo -o /etc/yum.repos.d/CentOS-Base.repo && \
	 sed -i '/aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
	 curl http://mirrors.aliyun.com/repo/epel-7.repo -o /etc/yum.repos.d/aliepel-7.repo && \
	 sed -i '/aliyuncs.com/d'  /etc/yum.repos.d/aliepel-7.repo && \
	 yum clean all && \
	 mkdir -p /root/.ssh && mkdir -p /work/depot 
RUN yum install -y cmake make bison \
		gcc gcc-c++ \
		openssl-devel \
		ncurses-devel \
		supervisor \
		openssh-server openssh-clients \
		net-tools
ADD inception.tar.gz /tmp/
ADD inc.cnf /etc/
WORKDIR /tmp/inception-master
RUN cmake -DWITH_DEBUG=OFF -DCMAKE_INSTALL_PREFIX=/usr/local/inception   -DMYSQL_DATADIR=./debug/data     -DWITH_SSL=bundled -DCMAKE_BUILD_TYPE=RELEASE -DWITH_ZLIB=bundled     -DMY_MAINTAINER_CXX_WARNINGS="-Wall -Wextra -Wunused -Wno-dev -Wwrite-strings -Wno-strict-aliasing  -Wno-unused-parameter -Woverloaded-virtual"     -DMY_MAINTAINER_C_WARNINGS="-Wall -Wextra -Wno-dev -Wunused -Wwrite-strings -Wno-strict-aliasing -Wdeclaration-after-statement" && \
	make -j4 && \
	make install && \
	make distclean

RUN yum remove -y  cmake make openssl-devel ncurses-devel  gcc gcc-c++ && \
	yum clean all && \
	rm -rf /tmp/inception-master

ENV http_proxy ''
ADD sshd.conf /etc/ssh/sshd_config
ADD id_rsa.pub /root/.ssh/authorized_keys
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
	ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
	sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd && \
	chmod 700 /root/.ssh && chmod 600 /root/.ssh/* && \
	chmod 755 /etc/inc.cnf
ADD supervisord.conf /etc/supervisord.conf
EXPOSE 10030 22

##### Clean

#ENTRYPOINT ["bash", "/tmp/init.sh"]
CMD ["/usr/bin/supervisord"]

##### CPAN:set auto install 
# RUN export PERL_MM_USE_DEFAULT=1
# RUN yum install -y cpan make gcc
# RUN cpan DBI DBD::mysql Config::Tiny Log::Dispatch Parallel::ForkManager 
##### CPAN

