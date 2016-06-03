# == Class: pg_monz
#
#  Installs pg_monz on the monitored server (the server that runs 
#  PostgreSQL / pgpool-II). 
#
# === Requirements
#
#  Requires 'zabbix-agent' class (puppet/zabbix module).
#
# === Parameters
#
# [*zabbix_user*]
#   User Zabbix agent runs under.
#   IMPORTANT: It doesn't change user account used by Zabbix agent, 
#              but only _informs_ pg_monz module about account that 
#              is actually used. 
#   Default:   zabbix
#
# [*zabbix_user_homedir*]
#   Home directory of the user Zabbix agent runs under.
#   IMPORTANT: It doesn't change the user's home directory, but only
#              _informs_ pg_monz module about the directory that is 
#              actually used. 
#   IMPORTANT: No trailing slash!
#   Default:   /var/lib/zabbix
#
# [*pghost*]
#   Used for PGHOST value in pgsql_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   127.0.0.1
#
# [*pgport*]
#   Used for PGPORT value in pgsql_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   5432
#
# [*pgrole*]
#   Used for PGROLE value in pgsql_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   postgres
#
# [*pgrolepassword*]
#   Password of user defined by pgrole. 
#   Default:   '' (empty)
#
# [*pgdatabase*]
#   Used for PGDATABASE value in pgsql_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   postgres
#
# [*pgpoolhost*]
#   Used for PGPOOLHOST value in pgpool_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   127.0.0.1
#
# [*pgpoolport*]
#   Used for PGPOOLPORT value in pgpool_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   9999
#
# [*pgpoolrole*]
#   Used for PGPOOLROLE value in pgpool_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   postgres
#
# [*pgpoolrolepassword*]
#   Password of user defined by pgpoolrole. 
#   Default:   '' (empty)
#
# [*pgpooldatabase*]
#   Used for PGPOOLDATABASE value in pgpool_funcs.conf file. 
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Default:   postgres
#
# [*pgpoollogdir*]
#   Directory where pgpool log files are stored.
#   IMPORTANT: No trailing slash!
#   Default:   /var/log/pgpool
#
# [*pgpoollogfile*]
#   pgpool log file name. The file has to be stored in pgpoollogdir.
#   IMPORTANT: Do not specify path! (It is assumed that the file is
#              stored in pgpoollogdir.)
#   Default:   pgpool.log
#
# [*pglogdir*]
#   Directory where PostgreSQL log files are stored.
#   IMPORTANT: No trailing slash!
#   Default:   /var/log/postgresql
#
# [*pglogfile*]
#   PostgreSQL log file name. The file has to be stored in pglogdir.
#   IMPORTANT: Do not specify path! (It is assumed that the file is
#              stored in pglogdir.)
#   Default:   postgresql-9.5-main.log
#
# [*scriptdir*]
#   Directory where pg_monz script files will be installed.
#   IMPORTANT: No trailing slash!
#   Default:   /usr/local/bin
#
# [*script_confdir*]
#   Directory where pg_monz script config files will be installed.
#   IMPORTANT: No trailing slash!
#   Default:   /usr/local/etc
#
# === Example
#
#  Basic installation:
#  class { 'pg_monz': }
#
#  With parameters that are often needed (often different than default ones):
#  class { 'pg_monz':
#     pgrolepassword => 'my_postgres_password', 
#     pgpoolconf     => '/etc/pgpool2/3.5.2/pgpool.conf', 
#     pglogfile      => 'postgresql-9.4-main.log', 
#  }
#
# === Authors
#
# Author Name: Fat Dragon www.itenlight.com
#
# === Copyright
#
# Copyright 2016 IT Enlight
#
class pg_monz (
  $zabbix_user = 'zabbix',
  $zabbix_user_homedir = '/var/lib/zabbix',
#pgsql_funcs.conf
  $pghost = '127.0.0.1',
  $pgport = 5432,
  $pgrole = 'postgres',
  $pgrolepassword = '',
  $pgdatabase = 'postgres',
#pgpool_funcs.conf
  $pgpoolhost = '127.0.0.1',
  $pgpoolport = 9999,
  $pgpoolrole = 'postgres',
  $pgpoolrolepassword = '',
  $pgpooldatabase = 'postgres',
  $pgpoolconf = '/usr/local/etc/pgpool.conf',
#files and directories
  $pgpoollogdir = '/var/log/pgpool',
  $pgpoollogfile = 'pgpool.log',
  $pglogdir = '/var/log/postgresql',
  $pglogfile = 'postgresql-9.5-main.log',
  $scriptdir = '/usr/local/bin',
  $script_confdir = '/usr/local/etc',
) {

  include zabbix::sender
  
  # zabbix user's home directory
  file { 'zabbix_user_homedir':
    ensure => 'directory',
    path   => $zabbix_user_homedir,
    owner  => $zabbix_user,
    mode   => '0750',
  }
  
  # zabbix user's PostgreSQL password file:  
  file { 'zabbix_user_pgpass_file':
    ensure  => 'file',
    path    => "${zabbix_user_homedir}/.pgpass",
    owner   => $zabbix_user,
    mode    => '0600',
    require => File['zabbix_user_homedir'],
  }

  # zabbix user's pgrole credentials: 
  file_line { 'zabbix_pgrole_credentials_line':
    ensure  => 'present',
    path    => "${zabbix_user_homedir}/.pgpass",
    line    => "*:*:${pgdatabase}:${pgrole}:${pgrolepassword}",
    match   => "^\\*\\:\\*\\:${pgdatabase}\\:${pgrole}\\:",
    require => File['zabbix_user_pgpass_file'],
  }
  
  if $pgpooldatabase != $pgdatabase or $pgpoolrole != $pgrole {
        
    # zabbix user's pgpoolrole credentials: 
    file_line { 'zabbix_pgpoolrole_credentials_line':
      ensure  => 'present',
      path    => "${zabbix_user_homedir}/.pgpass",
      line    => "*:*:${pgpooldatabase}:${pgpoolrole}:${pgpoolrolepassword}",
      match   => "^\\*\\:\\*\\:${pgpooldatabase}\\:${pgpoolrole}\\:",
      require => File['zabbix_user_pgpass_file'],
    }
    
  }
  
  # Log files permissions:
  file { 'pgpool.log':
    path => "${pgpoollogdir}/${pgpoollogfile}",
    mode => '0664',
  }
  
  file { 'postgresql.log':
    path => "${pglogdir}/${pglogfile}",
    mode => '0664',
  }
  
  # Scripts: 
  file { 'scriptdir':
    ensure => 'directory',
    path   => $scriptdir,
    mode   => '0755',
  }
  
  file { 'find_dbname.sh':
    ensure  => 'file',
    path    => "${scriptdir}/find_dbname.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/find_dbname.sh',
    require => File['scriptdir'],
  }
  
  file { 'find_dbname_table.sh':
    ensure  => 'file',
    path    => "${scriptdir}/find_dbname_table.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/find_dbname_table.sh',
    require => File['scriptdir'],
  }
  
  file { 'find_pgpool_backend.sh':
    ensure  => 'file',
    path    => "${scriptdir}/find_pgpool_backend.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/find_pgpool_backend.sh',
    require => File['scriptdir'],
  }
  
  file { 'find_pgpool_backend_ip.sh':
    ensure  => 'file',
    path    => "${scriptdir}/find_pgpool_backend_ip.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/find_pgpool_backend_ip.sh',
    require => File['scriptdir'],
  }
  
  file { 'find_sr.sh':
    ensure  => 'file',
    path    => "${scriptdir}/find_sr.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/find_sr.sh',
    require => File['scriptdir'],
  }
  
  file { 'find_sr_client_ip.sh':
    ensure  => 'file',
    path    => "${scriptdir}/find_sr_client_ip.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/find_sr_client_ip.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgpool_backend_status.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgpool_backend_status.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgpool_backend_status.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgpool_cache.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgpool_cache.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgpool_cache.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgpool_connections.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgpool_connections.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgpool_connections.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgpool_delegate_ip.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgpool_delegate_ip.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgpool_delegate_ip.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgpool_simple.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgpool_simple.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgpool_simple.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_db_funcs.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_db_funcs.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_db_funcs.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_primary.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_primary.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_primary.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_server_funcs.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_server_funcs.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_server_funcs.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_simple.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_simple.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_simple.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_sr_server_funcs.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_sr_server_funcs.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_sr_server_funcs.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_standby.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_standby.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_standby.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_tbl_funcs.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_tbl_funcs.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_tbl_funcs.sh',
    require => File['scriptdir'],
  }
  
  file { 'pgsql_userdb_funcs.sh':
    ensure  => 'file',
    path    => "${scriptdir}/pgsql_userdb_funcs.sh",
    owner   => $zabbix_user,
    mode    => '0754',
    source  => 'puppet:///modules/pg_monz/pgsql_userdb_funcs.sh',
    require => File['scriptdir'],
  }
  
  # Configs:
  file { 'script_confdir':
    ensure => 'directory',
    path   => $script_confdir,
    mode   => '0755',
  }
  
  file { 'pgsql_funcs.conf':
    ensure  => 'file',
    path    => "${script_confdir}/pgsql_funcs.conf",
    owner   => $zabbix_user,
    mode    => '0644',
    content => template('pg_monz/pgsql_funcs.conf.erb'),
    require => File['script_confdir'],
  }
  
  file { 'pgpool_funcs.conf':
    ensure  => 'file',
    path    => "${script_confdir}/pgpool_funcs.conf",
    owner   => $zabbix_user,
    mode    => '0644',
    content => template('pg_monz/pgpool_funcs.conf.erb'),
    require => File['script_confdir'],
  }
  
  # Zabbix conf:
  zabbix::userparameters { 'userparameter_pgsql':
    source  => 'puppet:///modules/pg_monz/userparameter_pgsql.conf',
  }

}
