#
# Cookbook Name:: zabbix2
# Attributes:: default
#
# Copyright 2014, Adam Balali
#
# All rights reserved - Do Not Redistribute
#

default['zabbix']['repo_alias']        = 'server_monitoring'
default['zabbix']['server_packages']   = ['libmysqlclient-devel', 'zabbix-server-mysql']
default['zabbix']['frontend_packages'] = ['zabbix-phpfrontend', 'apache2', 'apache2-mod_php53', 'php53-gettext', 'php53-mbstring', 'php53-gd', 'php53-mysql']
default['zabbix']['frontend']          = true
default['zabbix']['services']          = ['mysql', 'zabbix-server', 'apache2']
default['zabbix']['share_folder']      = '/usr/share/zabbix'
default['zabbix']['port']              = '80'
default['zabbix']['server_ip']         = '127.0.0.1'
default['zabbix']['owner']             = 'zabbixs'
default['zabbix']['group']             = 'zabbixs'
default['zabbix']['zabbix_release']    = '2.2'
default['zabbix']['secretpath']        = "#{Chef::Config[:file_cache_path]}/encrypted_data_bag_secret"
default['zabbix']['schemas_path']      = '/usr/share/doc/packages/zabbix-server/mysql/'

default['zabbix']['db']['database']       = 'zabbix'
default['zabbix']['db']['host']           = 'localhost'
default['zabbix']['db']['dump_file_path'] = '/usr/share/doc/packages/zabbix-server/mysql/'
default['zabbix']['db']['dump_files']     = ['schema.sql', 'images.sql', 'data.sql']

default['zabbix']['zabbix_agent']['name']      = 'zabbix-agent'
default['zabbix']['zabbix_agent']['url'] = 'http://www.zabbix.com/downloads/2.2.7/zabbix_agents_2.2.7.win.zip'
default['zabbix']['zabbix_agent']['install_target'] = 'C:\Zabbix'
default['zabbix']['zabbix_agent']['config_path']    = '/etc/zabbix/zabbix_agentd.conf'
default['zabbix']['zabbix_agent']['config_template'] = 'zabbix_agentd.conf.erb'

case node["platform"]
  when "suse"
    default['zabbix']['zabbix_repo'] = 'http://download.opensuse.org/repositories/server:/monitoring/SLE_11_SP3/'
    default['zabbix']['zabbix_agent']['name'] = 'zabbix-agentd'
    default['zabbix']['zabbix_agent']['config_path']    = '/etc/zabbix/zabbix-agentd.conf'
  when "redhat"
    default['zabbix']['zabbix_repo'] = 'http://repo.zabbix.com/zabbix/' +
        "#{node['zabbix']['zabbix_release']}/rhel/#{node['platform_version'].to_i}/" +
        "#{node[:kernel][:machine]}/zabbix-release-#{node['zabbix']['zabbix_release']}" +
        "-1.el#{node['platform_version'].to_i}.noarch.rpm"
    default['zabbix']['file_path'] = "#{Chef::Config[:file_cache_path]}/" +
        "zabbix-release-#{node['zabbix']['zabbix_release']}.el#{node['platform_version'].to_i}.noarch.rpm"
  when "ubuntu"
    default['zabbix']['zabbix_repo'] = 'http://repo.zabbix.com/zabbix/' +
        "#{node['zabbix']['zabbix_release']}/ubuntu/" +
        "pool/main/z/zabbix-release/zabbix-release_#{node['zabbix']['zabbix_release']}-1+#{node['lsb']['codename']}_all.deb"
    default['zabbix']['file_path'] = "#{Chef::Config[:file_cache_path]}/" +
        "zabbix-release_#{node['zabbix']['zabbix_release']}-1+#{node['lsb']['codename']}_all.deb"
  when "windows"
    default['zabbix']['zabbix_agent']['config_path'] = 'C:\Zabbix\zabbix_agentd.conf'
    default['zabbix']['zabbix_agent']['config_template'] = 'zabbix_agentd.win.conf.erb'
end