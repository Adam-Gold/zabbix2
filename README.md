Zabbix2 Cookbook
==================
This cookbook install zabbix-agent and zabbix-server.

By default the cookbook installs zabbix-agent, if you would like to install zabbix-server you should add zabbix2::server to your run_list

Default login password for zabbix frontend is admin / zabbix CHANGE IT !

Attributes
----------

#### zabbix2::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['zabbix']['server_ip']</tt></td>
    <td>String</td>
    <td>Set the Server IP Address</td>
    <td><tt>127.0.0.1</tt></td>
  </tr>
</table>

Usage
-----
Please include the default recipe before using any other recipe.

Installing the Agent:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix2]"
  ]
}
```

Installing the Server:
```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix2]",
    "recipe[zabbix2::server]"
  ]
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Adam Balali (adamba@johnbox.net)
