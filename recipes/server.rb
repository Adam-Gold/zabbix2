#
# Cookbook Name:: zabbix2
# Recipe:: server
#
# Copyright 2014, Adam Balali
#
# All rights reserved - Do Not Redistribute
#
if node["platform"] == "suse"
  include_recipe "database::mysql"

  zypper_repo "#{node['zabbix']['repo_alias']}" do
    repo "#{node['zabbix']['zabbix_repo']}"
  end

  cookbook_file "#{node['zabbix']['secretpath']}" do
    source "encrypted_data_bag_secret"
    owner 'root'
    group 'root'
    mode '0640'
  end

  ruby_block 'decrypt' do
    block do
      data_bag_default_path = Chef::Config[:data_bag_path]

      Chef::Config[:data_bag_path] = run_context.cookbook_collection['zabbix'].root_dir + '/data_bags'
      mysql_secret = Chef::EncryptedDataBagItem.load_secret("#{node['zabbix']['secretpath']}")
      node.set[:mysql_creds] = Chef::EncryptedDataBagItem.load("mysql", "credentials", mysql_secret)

      Chef::Config[:data_bag_path] = data_bag_default_path

      node.set[:mysql_connection_info] = {
          :host => node['zabbix']['db']['host'],
          :username => 'root',
          :password => node[:mysql_creds]['password']
      }

      node.set[:not_if_command] = "mysql -u root -p\"#{node[:mysql_creds]['password']}\" "
      node.set[:not_if_command] << "-D #{node['zabbix']['db']['database']} -e \"show tables;\" "
      node.set[:not_if_command] << "| grep #{node['zabbix']['db']['database']}"
      node.set[:import_schemas_command] = "mysql -u root -p\"#{node[:mysql_creds]['password']}\" zabbix < schema.sql; "
      node.set[:import_schemas_command] << "mysql -u root -p\"#{node[:mysql_creds]['password']}\" zabbix < images.sql; "
      node.set[:import_schemas_command] << "mysql -u root -p\"#{node[:mysql_creds]['password']}\" zabbix < data.sql; "
      node.set[:import_schemas_command] << "mysql -u root -p\"#{node[:mysql_creds]['password']}\" zabbix < auto_registration.sql"
    end
  end

  mysql_service 'default' do
    version node['zabbix']['db']['version']
    server_root_password lazy { node[:mysql_creds]['password'] }
    action :create
  end

  node['zabbix']['server_packages'].each do |install_package|
    package "#{install_package}" do
      action :install
    end
  end

  mysql_database "#{node['zabbix']['db']['database']}" do
    connection lazy { node[:mysql_connection_info] }
    action :create
  end

  mysql_database_user 'create_mysql_user' do
    username lazy { node[:mysql_creds]['username'] }
    connection lazy { node[:mysql_connection_info] }
    database_name node['zabbix']['db']['database']
    password lazy { node[:mysql_creds]['password'] }
    privileges [:all]
    action :grant
  end

  cookbook_file "#{node['zabbix']['schemas_path']}/auto_registration.sql" do
    source 'auto_registration.sql'
    owner lazy { node[:mysql_creds]['username'] }
    group lazy { node[:mysql_creds]['username'] }
    mode '0644'
  end

  ruby_block 'check_if_zabbix_schemas_created' do
    block do
      not_if_command = lambda { node[:not_if_command] }

      system("#{not_if_command.call}")
      exit_code = $?

      if exit_code.to_i != 0
        Dir.chdir("#{node['zabbix']['schemas_path']}") {
          %x[#{node[:import_schemas_command]}]
        }
      end
    end
  end

  template '/etc/zabbix/zabbix-server.conf' do
    source 'zabbix-server.conf.erb'
    mode '0640'
    owner 'root'
    group 'zabbixs'
    variables lazy { ({
                  :database => "#{node['zabbix']['db']['database']}",
                  :username => "#{node[:mysql_creds]['username']}",
                  :password => "#{node[:mysql_creds]['password']}"
              }) }
  end

  if node['zabbix']['frontend']
    node['zabbix']['frontend_packages'].each do |install_package|
      package "#{install_package}"
    end
  end

  execute 'enable_apache_php5_module' do
    command <<-EOH
    a2enmod php5
    a2enflag ZABBIX
    EOH
    action :run
  end

  remote_ip = node[:network][:interfaces][:eth0][:addresses].detect{|k,v| v[:family] == "inet" }.first

  template '/usr/share/zabbix/conf/zabbix.conf.php' do
    source 'zabbix.conf.php.erb'
    mode '0644'
    owner node['zabbix']['owner']
    group node['zabbix']['group']
    variables lazy { ({
                  :database  => "#{node['zabbix']['db']['database']}",
                  :username  => "#{node[:mysql_creds]['username']}",
                  :password  => "#{node[:mysql_creds]['password']}",
                  :remote_ip => "#{remote_ip}",
                  :port      => "#{node['zabbix']['port']}"
              }) }
  end

  template '/etc/apache2/listen.conf' do
    source 'listen.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables({
                  :port => "#{node['zabbix']['port']}"
              })
  end

  cookbook_file "/etc/php5/apache2/php.ini" do
    source "php.ini"
    owner 'root'
    group 'root'
    mode '0644'
  end

  node['zabbix']['services'].each do |zabbix_service|
    service "#{zabbix_service}" do
      action [:enable, :start]
    end
  end
else
  Chef::Log.info "#{node['platform']} is not supported yet."
end