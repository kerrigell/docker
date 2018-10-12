#!/bin/bash
#exec  1>>/var/log/init.sh.log 2>&1

case ${ROLE} in
	MYSQLM|MYSQL|MYSQLS)
		echo "`date +"%F %R"` Start MySQL Instance."
		cd /data
		PORT=${MYSQL_PORT:=3306}
		INNOBUFFER=${INNOBUFFER:=20M}
		datadir=/data/my${MYSQL_PORT}
		max_connection=${MAXCONNECTION:=10}
		mycnf=/etc/mysql/my${PORT}.cnf
#		#mycnf=/etc/mysql/my${PORT}.cnf
		if [[ ! -e ${mycnf} ]]; then
			echo "`date +"%F %R"` Make MySQL Config:${mycnf}"
			mkdir -p ${datadir}
			serverid=`head -200 /dev/urandom | cksum | cut -f1 -d" "`
			cp /etc/mysql/my.tpl ${mycnf}
			sed -i "s#{DATADIR}#${datadir}#g" ${mycnf}
			sed -i "s#{PORT}#${PORT}#g" ${mycnf}
			sed -i "s#{INNOBUFFER}#${INNOBUFFER}#g" ${mycnf}
			sed -i "s#{SERVERID}#${serverid}#g" ${mycnf}
			sed -i "s#{MAXCONNECTION}#${max_connection}#g" ${mycnf}
		fi
		chown -R mysql:mysql ${datadir}
		if [[ ! (-d ${datadir} && -e ${datadir}/mysql/ && $(du -s ${datadir}/mysql/ | awk '{print $1}') -gt 0) ]]; then
			echo "`date +"%F %R"` Init MySQL DATA:${mycnf}"
			/usr/sbin/mysqld  --defaults-file=${mycnf} --initialize-insecure --console
			ln -s ${datadir}/my${PORT}.sock /var/lib/mysql/mysql.sock
		fi
		if [[ "$?" == "0" ]]; then
			echo "`date +"%F %R"` Change supervisor Config"
			sed -i -e ":begin; /mysqld/,/logfile/ {  s/autostart=false/autostart=true/;};" /etc/supervisord.conf
			sed -i -e "s#command=/usr/bin/mysqld_safe.*#command=/usr/sbin/mysqld  --defaults-file=${mycnf} --daemonize  --daemonize#" /etc/supervisord.conf
		fi
	;;
	MYSQLS)
	;;
	MHAM)
		mkdir -p /etc/masterha/
		mkdir -p /var/log/masterha/
	;;
	*)
	echo "Usage"
esac

/usr/bin/supervisord

if [[ ${MYUSER} ]]; then
    sleep 5
    echo "create mysql user: ${MYUSER:=}"
    mysql << EOF
grant all on *.* to '${MYUSER}'@'${MYHOST:=%}'indentified by '${MYPWD:=}';
EOF
fi
