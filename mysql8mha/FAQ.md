# docker 安装 mha

## 环境依赖

* 网络受限
	> 配置系统代理变量
	> export http_proxy=10.199.75.10:8080
* perl模块依赖
	`yum install -y perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager `
    > perl-Log-Dispatch 包在ali源里没有,需要安装其EPEL源
    > 或者，使用CPAN进行源码安装，配置见下[CPAN初始化]
* CPAN初始化
	> 1. 安装cpan
	> 		yum install -y cpan
	> 2. 创建文件/root/.cpan/CPAN/MyConfig.pm
	>        $CPAN::Config = {
	>			'urllist' => [q[http://mirrors.aliyun.com/CPAN/]],
	>		};
	>		1;
	> 3. 设置自动安装
	> 		export PERL_MM_USE_DEFAULT=1
	> 4. 安装编译工具：make gcc
	> 5. 安装perl依赖模块
		`cpan DBI DBD::mysql Config::Tiny Log::Dispatch Parallel::ForkManager`
  	> 		DBD::mysql错误：Can't exec "mysql_config": No such file or directory at Makefile.PL line 540.

## MHA编译
* cd mha4mysql-manager-master
* perl Makefile.PL
* make
* make install


## DockerFile
* Package mariadb-libs is obsoleted by Percona-Server-shared-55, but obsoleting package does not provide for requirements
> yum remove mariadb-libs


## ssh
* debug1: key_load_public: No such file or directory
	> 文件权限和sshd配置
		RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
		RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
		RUN sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd
		RUN mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh
* Could not load host key: /etc/ssh/ssh_host_rsa_key
	> RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
	> RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
* Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
	> root登陆：PermitRootLogin yes
* PAM: pam_open_session(): Cannot make/remove an entry for the specified session
	> Just comment this line in file “/etc/pam.d/sshd”:
	> session required        pam_loginuid.so
* key要相互信任

## MySQL
* 2016-11-16 08:23:50 1166 [ERROR] /usr/sbin/mysqld: unknown variable 'defaults-file=/etc/mysql/my3306.cnf'
	> /usr/local/mysql/bin/mysqld_safe--defaults-file=/usr/local/mysql/my.cnf--user=mysql
	> --defaults-file必须放到第一位
* 使用my.cnf模板在容器启动时进行初始化和配置文件处理
* 如何解决mysql服务器启动后，进行权限等配置
	* 可以使用consul等触发
	* mysql_install_db 时配置（繁琐，不好扩展）

## supervisor
* supervisorctrl不能使用
	* 没有创建socket文件
	* error: <class 'socket.error'>, [Errno 2] No such file or directory: file: /usr/lib64/python2.7/socket.py line: 224

## Replication
*  grant replication slave on *.* to 'repl'@'172.%' identified by 'repl';
*  change master to master_host='172.17.0.2',master_port=3306,master_user='repl',master_password='repl',master_auto_position=1;
*  start slave;


## docker
* entrypoint: 使容器看起来像可执行程序，可在后面跟参数
    > FROM ubuntu
    > ENTRYPOINT [“echo”]
    > docker run image2 echo hello
    > 输出 echo hello
* cmd：可作为entrypoint参数
* start时cmd entrypoint是否执行？


## mha
### masterha_check_ssh
* bash: ssh: command not found
	> yum install openssh-client
	> 需要先安装ssh client，再编译masterha
	> 需要所有节点ssh相互信任

### masterha_check_repl
*  Perhaps the DBD::mysql perl module hasn't been fully installed,or perhaps the capitalisation of 'mysql' isn't right.
	> 尝试先安装mysql再编译masterha，因为在安percona前卸载了yum remove -y  mariadb-libs
* Thu Nov 17 08:08:29 2016 - [error][/usr/local/share/perl5/MHA/ServerManager.pm, ln188] There is no alive server. We can't do failover
	> debug info: Thu Nov 17 09:04:42 2016 - [debug] Got MySQL error when connecting 172.17.0.2(172.17.0.2:3306) :2005:Unknown MySQL server host '[172.17.0.2]' (0)
	> 手动连接测试没问题
	> 因编译的masterha是从github下载的最新版，可能是0.5.7
	> 网上rpm是0.5.6 版本没有此问题
	> 代码问题：/usr/local/share/perl5/MHA/DBHelper.pm
            185 sub connect {
            186   my $self        = shift;
            187   my $host        = shift;
            188   my $port        = shift;
            189   my $user        = shift;
            190   my $password    = shift;
            191   my $raise_error = shift;
            192   my $max_retries = shift;
            193   $raise_error = 0 if ( !defined($raise_error) );
            194   $max_retries = 2 if ( !defined($max_retries) );
            195
            196   $self->{dbh} = undef;
            197   unless ( $self->{dsn} ) {
            198     $self->{dsn} = "DBI:mysql:;host=[$host];port=$port;mysql_connect_timeout=4"; 这里的[$host]问题，改为$host
            199   }
            200   my $defaults = {
	> 资讯：http://blog.takanabe.tokyo/2016/05/04/2410/

### masterha_manager
> masterha_manager --conf=/etc/masterha/app1.conf > /var/log/masterha/app1/run.log













