name             'zabbix2'
maintainer       'Adam Balali'
maintainer_email 'adamba@johnbox.net'
license          'All rights reserved'
description      'Installs/Configures Zabbix Agent/Server'
long_description <<-TEXT
This cookbook install zabbix-agent and zabbix-server.
By default the cookbook installs zabbix-agent, if you would like to install zabbix-server you should add zabbix2::server to your run_list
Default login password for zabbix frontend is admin / zabbix CHANGE IT !
TEXT
version          '0.1.0'

%w{ ubuntu suse redhat centos windows }.each do |os|
  supports os
end

depends 'database', '2.3.1'
depends 'mysql'
depends 'windows', '1.34.8'