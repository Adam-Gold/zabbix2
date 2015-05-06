define :zypper_repo do
  zypper_command = "zypper ar -f "
  zypper_command << "#{params[:repo]} "
  zypper_command << "\"#{params[:name]}\""

  execute 'add_zabbix_repo' do
    command zypper_command
    user 'root'
    not_if "zypper repos | grep \"#{params[:name]}\""
  end

  execute 'zypper_update' do
    command 'zypper update -y'
    user 'root'
  end
end