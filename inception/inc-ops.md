# Inception-MySqL

## requirement
* cmake
* make
* openssl openssl-devel
* ncurses-devel
* bison
* gcc gcc-c++
	> warning: /var/cache/yum/x86_64/7/base/packages/bison-2.7-4.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for bison-2.7-4.el7.x86_64.rpm is not installed

## build
* cmake -DWITH_DEBUG=OFF -DCMAKE_INSTALL_PREFIX=/usr/local/inception   -DMYSQL_DATADIR=./debug/data     -DWITH_SSL=bundled -DCMAKE_BUILD_TYPE=RELEASE -DWITH_ZLIB=bundled     -DMY_MAINTAINER_CXX_WARNINGS="-Wall -Wextra -Wunused -Wno-dev -Wwrite-strings -Wno-strict-aliasing  -Wno-unused-parameter -Woverloaded-virtual"     -DMY_MAINTAINER_C_WARNINGS="-Wall -Wextra -Wno-dev -Wunused -Wwrite-strings -Wno-strict-aliasing -Wdeclaration-after-statement"
	1. CMake Error: your C compiler: "CMAKE_C_COMPILER-NOTFOUND" was not found.   Please set CMAKE_C_COMPILER to a valid compiler path or name.
CMake Error: your CXX compiler: "CMAKE_CXX_COMPILER-NOTFOUND" was not found.   Please set CMAKE_CXX_COMPILER to a valid compiler path or name.
	> yum install gcc gcc-c++

	2. -- Could NOT find Threads (missing:  Threads_FOUND) -- Could NOT find Threads (missing:  Threads_FOUND)
	> 删除CMakeCache.txt

* make -j4
* make install

## run
* /usr/local/inception/bin/Inception --defaults-file=/etc/inc.cnf

## Config
    [inception]
    character-set-server=utf8
    character-set-client-handshake=0
    general_log=1
    general_log_file=/var/log/inception.log
    inception_check_autoincrement_datatype=1
    inception_check_autoincrement_init_value=1
    inception_check_autoincrement_name=1
    inception_check_column_comment=0
    inception_check_column_default_value=1
    inception_check_dml_limit=1
    inception_check_dml_orderby=1
    inception_check_dml_where=1
    inception_check_index_prefix=0
    inception_check_insert_field=1
    inception_check_identifier=1
    inception_check_primary_key=1
    inception_check_table_comment=0
    inception_check_timestamp_default=1
    inception_enable_autoincrement_unsigned=0
    inception_enable_blob_type=1
    inception_enable_column_charset=1
    inception_enable_enum_set_bit=0
    inception_enable_foreign_key=0
    inception_enable_identifer_keyword=0
    inception_enable_not_innodb=0
    inception_enable_nullable=1
    inception_enable_orderby_rand=1
    inception_enable_partition_table=0
    inception_enable_select_star=0
    inception_enable_sql_statistic=0
    inception_max_char_length=16
    inception_max_key_parts=6
    inception_max_keys=25
    inception_max_update_rows=10000
    inception_merge_alter_table=1
    inception_osc_bin_dir=/tmp/inception
    inception_osc_chunk_time=0.1
    inception_osc_min_table_size=1
    inception_read_only=1
    inception_remote_backup_host=10.209.5.196
    inception_remote_backup_port=3401
    inception_remote_system_password=inception
    inception_remote_system_user=inception
    inception_support_charset=utf8,utf8mb4
    port=10030
    socket=/var/run/inc.sock
    #
    inception_ddl_support=1







