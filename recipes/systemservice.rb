#
# Cookbook Name:: virtualbox
# Recipe:: systemservice
#
# Copyright 2012, Ringo De Smet
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

extend Vbox::Helpers

def vbox_dir(dirname)
  directory dirname do
    mode '1775'
    recursive true
    user node[cookbook_name]['user']
    group node[cookbook_name]['group']
  end
end

include_recipe "#{cookbook_name}::user"

vbox_dir node[cookbook_name]['config_folder']
vbox_dir node[cookbook_name]['autostartfolder']
vbox_dir node[cookbook_name]['autostart_db_folder']

cookbook_file node[cookbook_name]['autostart_machines_file'] do
  source 'machines_enabled'
  mode '0664'
  user node[cookbook_name]['user']
  group node[cookbook_name]['group']
  not_if FileTest.exists?(node[cookbook_name]['autostart_machines_file']).to_s
end

template node[cookbook_name]['config_file'] do
  source 'vbox.cfg.erb'
  user node[cookbook_name]['user']
  group node[cookbook_name]['group']
  mode '0664'
  variables(user: node[cookbook_name]['user'], webservice_log: node[cookbook_name]['webservice']['log'], autostart_config_file: node[cookbook_name]['autostart_config_file'], autostart_db_folder: node[cookbook_name]['autostart_db_folder'])
end

template node[cookbook_name]['autostart_config_file'] do
  source 'vboxautostart.conf.erb'
  user node[cookbook_name]['user']
  group node[cookbook_name]['group']
  mode '0664'
  variables(users: node[cookbook_name]['autostart_users'])
end

template '/etc/init.d/vboxcontrol' do
  source 'vboxcontrol.erb'
  mode '0755'
  variables(user: node[cookbook_name]['user'], autostart_machines_file: node[cookbook_name]['autostart_machines_file'], vboxcontrol_config_file: node[cookbook_name]['vboxcontrol_config_file'])
end

Chef::Log.warn("node[cookbook_name]['user'] = #{node[cookbook_name]['user']}")

execute 'enable virtualbox autostart' do
  user node[cookbook_name]['user']
  group node[cookbook_name]['group']
  login true
  command "VBoxManage setproperty autostartdbpath #{node[cookbook_name]['autostart_db_folder']}"
end

service 'vboxcontrol' do
  action [:enable, :start]
end
