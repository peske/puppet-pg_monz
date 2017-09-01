# pg_monz #

The module installs and configures [pg_monz monitoring Zabbix template](http://pg-monz.github.io/pg_monz/index-en.html).

The complete tutorial can be found at [Puppet, Zabbix, PostgreSQL and pgpool-II Together - pg_monz Module](https://www.itenlight.com/blog/2016/06/02/Puppet%2C+Zabbix%2C+PostgreSQL+and+pgpool-II+Together+-+pg_monz+Module).

## Server Side

At the server side (at Zabbix server), the module only installs the following Zabbix templates:
* Template App PostgreSQL
* Template App PostgreSQL SR
* Template App PostgreSQL SR Cluster
* Template App pgpool-II
* Template App pgpool-II watchdog

**Note:** Although all the templates are installed, which will be used for a particular client depends on the client's configuration. See [Creating Host section](http://pg-monz.github.io/pg_monz/index-en.html#creating-host) in the original documentation.

### Server Side Requirements

The module requires 'zabbix' class at the server side. See [puppet/zabbix module](https://forge.puppet.com/puppet/zabbix) at puppet forge).

### pg_monz Server Side Example

```
class { 'pg_monz::server': }
```

**Note:** The class will automatically install the templates only if you're using [puppet/zabbix module](https://forge.puppet.com/puppet/zabbix) with `manage_resources` set to `true`. For details check [Puppet, Zabbix, PostgreSQL and pgpool-II Together - pg_monz Module](https://www.itenlight.com/blog/2016/06/02/Puppet%2C+Zabbix%2C+PostgreSQL+and+pgpool-II+Together+-+pg_monz+Module).

## Client Side

At the client side (monitored PostgreSQL / pgpool-II server) the module installs pg_monz scripts and configuration files.

### Client Side Requirements

The module requires 'zabbix-agent' and 'zabbix-sender' classes at the client side. Again, see [puppet/zabbix module](https://forge.puppet.com/puppet/zabbix) at puppet forge).

### pg_monz Client Side Examples

Basic example (with default values) is pretty simple:

```
class { 'pg_monz': }
```

In reality however, chances are that you'll have to specify some parameters. An example with parameters that are often different than default values:

```
class { 'pg_monz':
  pgrolepassword => 'my_postgres_password', 
  pgpoolconf     => '/etc/pgpool2/3.5.2/pgpool.conf', 
  pglogfile      => 'postgresql-9.4-main.log', 
}
```

## Release History

### v0.1.6

**Date:** September 1. 2017

**Release Info:**
* Code cosmetics (thanks to puppet-lint).

### v0.1.5

**Date:** Jun 9. 2016

**Release Info:**
* `zabbix_user` parameter added to `pg_monz::server` class;
* Hard-codded `templates_dir` resource replaced with `ensure_resource()`;
* Confirmed compatibility with CentOS.

### v0.1.4

**Date:** Jun 3. 2016

**Release Info:**
* Metadata cosmetics, to satisfy puppet forge criteria.

### v0.1.3

**Date:** Jun 3. 2016

**Release Info:**
* Using `'/bin/true'` instead of `'true'` to avoid negative quality points.

### v0.1.2

**Date:** Jun 3. 2016

**Release Info:**
* A bug caused by puppet-lint auto fix (removing quotes from 'true') fixed.

### v0.1.1

**Date:** Jun 3. 2016

**Release Info:**
* Code cosmetics (thanks to puppet-lint).

### v0.1.0

**Date:** Jun 3. 2016

**Release Info:**
* Initial release.