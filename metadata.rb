name             'zabbix2'
maintainer       'Adam Balali'
maintainer_email 'adamba@johnbox.net'
license          'All rights reserved'
description      'Installs/Configures Zabbix Agent/Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'
source_url       'https://github.com/AdamBalali/zabbix2'

%w{ ubuntu suse redhat centos windows }.each do |os|
  supports os
end

depends 'database', '2.3.1'
depends 'mysql'
depends 'windows', '1.34.8'