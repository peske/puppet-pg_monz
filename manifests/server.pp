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
# [*install_templates*]
#   Whether to install templates or not. Actually since the class
#   doesn't do anything else besides installing templates, setting
#   this parameter to false has the same effect as removing the
#   the class completely.
#   Default:   true
#
# [*zabbix_agentd_conf*]
#   Sets default {$ZABBIX_AGENTD_CONF} macro value.
#   See http://pg-monz.github.io/pg_monz/index-en.html for details.
#   Macro value can be changed later through Zabbix web interface.
#   Default:   /etc/zabbix/zabbix_agentd.conf
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
  $install_templates = true,
  $zabbix_agentd_conf = '/etc/zabbix/zabbix_agentd.conf',
  $pg_host_group = 'PostgreSQL',
  $pgscriptdir = '/usr/local/bin',
  $pgscript_confdir = '/usr/local/etc',
  $pglogdir = '/var/log/postgresql',
  $pgpool_host_group = 'pgpool',
  $pgpoollogdir = '/var/log/pgpool',
  $pgpoolscriptdir = '/usr/local/bin',
  $pgpoolscript_confdir = '/usr/local/etc',
) {

  if $install_templates {
      
    $templates_dir = $zabbix::params::zabbix_template_dir
    
    file { 'templates_dir':
      ensure  => directory,
      path    => $templates_dir,
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0644',
      require => Class['zabbix'],
    }
    
    exec { 'check Template App pgpool-II watchdog':
      command => true,
      path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin', '/usr/local/sbin',
                  '/usr/local/bin'],
      onlyif  => "test ! -f ${templates_dir}/Template App pgpool-II watchdog.xml",
      require => File['templates_dir'],
    }
    
    file { 'Template_App_pgpool-II_watchdog.xml':
      path    => '/tmp/Template_App_pgpool-II_watchdog.xml',
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0644',
      content => template('pg_monz/Template_App_pgpool-II_watchdog.xml.erb'),
      require => Exec['check Template App pgpool-II watchdog'],
    }
    
    zabbix::template { 'Template App pgpool-II watchdog':
      templ_name   => 'Template App pgpool-II watchdog',
      templ_source => '/tmp/Template_App_pgpool-II_watchdog.xml',
      require      => [ File['Template_App_pgpool-II_watchdog.xml'],
                        Exec['check Template App pgpool-II watchdog'] ],
    }
    
    exec { 'check Template App pgpool-II':
      command => true,
      path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin', '/usr/local/sbin',
                  '/usr/local/bin'],
      onlyif  => "test ! -f ${templates_dir}/Template App pgpool-II.xml",
      require => File['templates_dir'],
    }
    
    file { 'Template_App_pgpool-II.xml':
      path    => '/tmp/Template_App_pgpool-II.xml',
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0644',
      content => template('pg_monz/Template_App_pgpool-II.xml.erb'),
      require => Exec['check Template App pgpool-II'],
    }
    
    zabbix::template { 'Template App pgpool-II':
      templ_name   => 'Template App pgpool-II',
      templ_source => '/tmp/Template_App_pgpool-II.xml',
      require      => [ File['Template_App_pgpool-II.xml'],
                        Exec['check Template App pgpool-II'] ],
    }
    
    exec { 'check Template App PostgreSQL SR Cluster':
      command => true,
      path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin', '/usr/local/sbin',
                  '/usr/local/bin'],
      onlyif  => "test ! -f ${templates_dir}/Template App PostgreSQL SR Cluster.xml",
      require => File['templates_dir'],
    }
    
    file { 'Template_App_PostgreSQL_SR_Cluster.xml':
      path    => '/tmp/Template_App_PostgreSQL_SR_Cluster.xml',
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0644',
      content => template('pg_monz/Template_App_PostgreSQL_SR_Cluster.xml.erb'),
      require => Exec['check Template App PostgreSQL SR Cluster'],
    }
    
    zabbix::template { 'Template App PostgreSQL SR Cluster':
      templ_name   => 'Template App PostgreSQL SR Cluster',
      templ_source => '/tmp/Template_App_PostgreSQL_SR_Cluster.xml',
      require      => [ File['Template_App_PostgreSQL_SR_Cluster.xml'],
                        Exec['check Template App PostgreSQL SR Cluster'] ],
    }
    
    exec { 'check Template App PostgreSQL':
      command => true,
      path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin', '/usr/local/sbin',
                  '/usr/local/bin'],
      onlyif  => "test ! -f ${templates_dir}/Template App PostgreSQL.xml",
      require => File['templates_dir'],
    }
    
    file { 'Template_App_PostgreSQL.xml':
      path    => '/tmp/Template_App_PostgreSQL.xml',
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0644',
      content => template('pg_monz/Template_App_PostgreSQL.xml.erb'),
      require => Exec['check Template App PostgreSQL'],
    }
    
    zabbix::template { 'Template App PostgreSQL':
      templ_name   => 'Template App PostgreSQL',
      templ_source => '/tmp/Template_App_PostgreSQL.xml',
      require      => [ File['Template_App_PostgreSQL.xml'],
                        Exec['check Template App PostgreSQL'] ],
    }
    
    exec { 'check Template App PostgreSQL SR':
      command => true,
      path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin', '/usr/local/sbin',
                  '/usr/local/bin'],
      onlyif  => "test ! -f ${templates_dir}/Template App PostgreSQL SR.xml",
      require => File['templates_dir'],
    }
    
    file { 'Template_App_PostgreSQL_SR.xml':
      path    => '/tmp/Template_App_PostgreSQL_SR.xml',
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0644',
      content => template('pg_monz/Template_App_PostgreSQL_SR.xml.erb'),
      require => Exec['check Template App PostgreSQL SR'],
    }
    
    zabbix::template { 'Template App PostgreSQL SR':
      templ_name   => 'Template App PostgreSQL SR',
      templ_source => '/tmp/Template_App_PostgreSQL_SR.xml',
      require      => [ File['Template_App_PostgreSQL_SR.xml'],
                        Exec['check Template App PostgreSQL SR'],
                        Zabbix::Template['Template App PostgreSQL'] ],
    }
    
  }
  
}