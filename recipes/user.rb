#
# Cookbook Name:: virtualbox
# Recipe:: user
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

# For the user to be created successfully, a data bag item with the MD5 hashed password
# needs to be added.
chef_gem 'unix-crypt' do
  action :upgrade
end

chef_gem 'chef-vault'

require 'chef-vault'
require 'unix_crypt'
extend Vbox::Helpers

case ChefVault::Item.data_bag_item_type(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'])
when :normal
  virtualbox_user_password = data_bag_item(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'])['password']
when :encrypted
  virtualbox_user_password = data_bag_item(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'], data_bag_item(node[cookbook_name]['secretdatabag'], node[cookbook_name]['secretdatabagitem'])[node[cookbook_name]['secretdatabagkey']])['password']
when :vault
  virtualbox_user_password = ChefVault::Item.load(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'])['password']
end unless data_bag(node[cookbook_name]['userdatabag']).nil? || data_bag(node[cookbook_name]['userdatabag']).empty?

# convert clear to encrypted "#{UnixCrypt::SHA512.build(data_bag_item('passwords',node[cookbook_name]['user'])['password'])}"

user node[cookbook_name]['user'] do
  extend Vbox::Helpers
  extend UnixCrypt
  username node[cookbook_name]['user']
  gid node[cookbook_name]['group']
  password UnixCrypt::SHA512.build(virtualbox_user_password)
  # home node[cookbook_name]['user'] == default_apache_user ? default_docroot_dir : "/home/#{node[cookbook_name]['user']}"
  shell '/bin/bash'
  system true
  manage_home true
  # notifies :stop, "service[#{apache_platform_service_name}]", :before if node[cookbook_name]['user'] == default_apache_user
end
