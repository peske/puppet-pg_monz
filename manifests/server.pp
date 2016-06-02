# == Class: pg_monz::server
#
#  Installs pg_monz templates on Zabbix server. 
#
# === Requirements
#
#  Requires 'zabbix' class (puppet/zabbix module).
#
# === Parameters
#
# [*templates_dir*]
#   Directory where template xml files will be stored.
#   IMPORTANT: No trailing slash!
#   Default:   /etc/zabbix/templates
#
# [*zabbix_agentd_conf*]
#   Sets default {$ZABBIX_AGENTD_CONF} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface.
#   Default:   /etc/zabbix/zabbix_agentd.conf
#
# [*pgpool_host_group*]
#   Sets default {$PGPOOL_HOST_GROUP} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface.
#   Default:   pgpool
#
# [*pgpoollogdir*]
#   Sets default {$PGPOOLLOGDIR} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface, 
#   but finally it should match to pg_monz::pgpoollogdir set at 
#   client side.
#   IMPORTANT: No trailing slash!
#   Default:   /var/log/pgpool
#
# [*pgpoolscriptdir*]
#   Sets default {$PGPOOLSCRIPTDIR} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface, 
#   but finally it should match to pg_monz::scriptdir set at 
#   client side.
#   IMPORTANT: No trailing slash!
#   Default:   /usr/local/bin
#
# [*pgpoolscript_confdir*]
#   Sets default {$PGPOOLSCRIPT_CONFDIR} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface, 
#   but finally it should match to pg_monz::script_confdir set at 
#   client side.
#   IMPORTANT: No trailing slash!
#   Default:   /usr/local/etc
#
# [*pg_host_group*]
#   Sets default {$PG_HOST_GROUP} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface.
#   Default:   PostgreSQL
#
# [*pgscriptdir*]
#   Sets default {$PGSCRIPTDIR} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface, 
#   but finally it should match to pg_monz::scriptdir set at client
#   side.
#   IMPORTANT: No trailing slash!
#   Default:   /usr/local/bin
#
# [*pgscript_confdir*]
#   Sets default {$PGSCRIPT_CONFDIR} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface, 
#   but finally it should match to pg_monz::script_confdir set at 
#   client side.
#   IMPORTANT: No trailing slash!
#   Default:   /usr/local/etc
#
# [*pglogdir*]
#   Sets default {$PGLOGDIR} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface, 
#   but finally it should match to pg_monz::pglogdir set at client
#   side.
#   IMPORTANT: No trailing slash!
#   Default:   /var/log/postgresql
#
# === Example
#
#  Basic installation:
#  class { 'pg_monz::server': }
#
# === Authors
#
# Author Name: Fat Dragon www.itenlight.com
#
# === Copyright
#
# Copyright 2016 IT Enlight
#
class pg_monz::server (
  $templates_dir = '/etc/zabbix/templates', 
  $zabbix_agentd_conf = '/etc/zabbix/zabbix_agentd.conf', 
  $pgpool_host_group = 'pgpool', 
  $pgpoollogdir = '/var/log/pgpool', 
  $pgpoolscriptdir = '/usr/local/bin', 
  $pgpoolscript_confdir = '/usr/local/etc', 
  $pg_host_group = 'PostgreSQL', 
  $pgscriptdir = '/usr/local/bin', 
  $pgscript_confdir = '/usr/local/etc', 
  $pglogdir = '/var/log/postgresql', 
) {

  file { 'templates_dir': 
    path    => $templates_dir, 
    ensure  => directory, 
    owner   => 'zabbix', 
    mode    => '0644', 
    require => Class['zabbix'], 
  }
  
  file { 'Template_App_pgpool-II_watchdog.xml': 
    path    => "${templates_dir}/Template_App_pgpool-II_watchdog.xml", 
    owner   => 'zabbix', 
    mode    => '0644', 
    content => template('fdpg_monz/Template_App_pgpool-II_watchdog.xml.erb'), 
    require => File['templates_dir'], 
  }
  
  zabbix-template { 'Template App pgpool-II watchdog': 
    templ_name   => 'Template App pgpool-II watchdog', 
    templ_source => "${templates_dir}/Template_App_pgpool-II_watchdog.xml", 
    require      => File['Template_App_pgpool-II_watchdog.xml'], 
  }
  
  file { 'Template_App_pgpool-II.xml': 
    path    => "${templates_dir}/Template_App_pgpool-II.xml", 
    owner   => 'zabbix', 
    mode    => '0644', 
    content => template('fdpg_monz/Template_App_pgpool-II.xml.erb'), 
    require => File['templates_dir'], 
  }
  
  zabbix-template { 'Template App pgpool-II': 
    templ_name   => 'Template App pgpool-II', 
    templ_source => "${templates_dir}/Template_App_pgpool-II.xml", 
    require      => File['Template_App_pgpool-II.xml'], 
  }
  
  file { 'Template_App_PostgreSQL_SR_Cluster.xml': 
    path    => "${templates_dir}/Template_App_PostgreSQL_SR_Cluster.xml", 
    owner   => 'zabbix', 
    mode    => '0644', 
    content => template('fdpg_monz/Template_App_PostgreSQL_SR_Cluster.xml.erb'), 
    require => File['templates_dir'], 
  }
  
  zabbix-template { 'Template App PostgreSQL SR Cluster': 
    templ_name   => 'Template App PostgreSQL SR Cluster', 
    templ_source => "${templates_dir}/Template_App_PostgreSQL_SR_Cluster.xml", 
    require      => File['Template_App_PostgreSQL_SR_Cluster.xml'], 
  }
  
  file { 'Template_App_PostgreSQL_SR.xml': 
    path    => "${templates_dir}/Template_App_PostgreSQL_SR.xml", 
    owner   => 'zabbix', 
    mode    => '0644', 
    content => template('fdpg_monz/Template_App_PostgreSQL_SR.xml.erb'), 
    require => File['templates_dir'], 
  }
  
  zabbix-template { 'Template App PostgreSQL SR': 
    templ_name   => 'Template App PostgreSQL SR', 
    templ_source => "${templates_dir}/Template_App_PostgreSQL_SR.xml", 
    require      => File['Template_App_PostgreSQL_SR.xml'], 
  }
  
  file { 'Template_App_PostgreSQL.xml': 
    path    => "${templates_dir}/Template_App_PostgreSQL.xml", 
    owner   => 'zabbix', 
    mode    => '0644', 
    content => template('fdpg_monz/Template_App_PostgreSQL.xml.erb'), 
    require => File['templates_dir'], 
  }
  
  zabbix-template { 'Template App PostgreSQL': 
    templ_name   => 'Template App PostgreSQL', 
    templ_source => "${templates_dir}/Template_App_PostgreSQL.xml", 
    require      => File['Template_App_PostgreSQL.xml'], 
  }
  
}