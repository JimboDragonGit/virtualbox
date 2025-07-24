#
# Cookbook Name:: virtualbox
# Recipe:: webportal
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

# The phpvirtualbox webportal requires the Virtualbox webservice api to be active

extend Vbox::Helpers
include_recipe '::webservice'

# This recipe requires the apache2 cookbook to be available
# include_recipe 'apache2'
# include_recipe "apache2::mod_php5"

service 'apache2' do
  service_name apache_platform_service_name
  supports restart: true, status: true
  action :nothing
end

apache2_install 'virtualbox-apache2' do
  apache_user default_apache_user
  apache_group default_apache_group
  mpm 'prefork'
  docroot_dir default_docroot_dir
  listen node['virtualbox']['webportal']['ports']
end

apache2_mod_php 'virtualbox-apache2'

package %w(php-xml php-soap php-json)

directory ::File.join(default_docroot_dir,'phpvirtualbox') do
  user default_apache_user
  group default_apache_group
  recursive true
end

git ::File.join(default_docroot_dir,'phpvirtualbox') do
  repository 'https://github.com/phpvirtualbox/phpvirtualbox.git'
  action :sync
  checkout_branch 'develop'
  enable_checkout false
  user default_apache_user
  group default_apache_group
end

directory ::File.join(::File.join(default_docroot_dir, 'phpvirtualbox'), '.git') do
  action :delete
  recursive true
end

template ::File.join(::File.join(default_docroot_dir, 'phpvirtualbox'), 'config.php') do
  source 'config.php.erb'
  mode '0644'

  case ChefVault::Item.data_bag_item_type(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'])
  when :normal
    password = data_bag_item(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'])['password']
  when :encrypted
    password = data_bag_item(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'], data_bag_item(node[cookbook_name]['secretdatabag'], node[cookbook_name]['secretdatabagitem'])[node[cookbook_name]['secretdatabagkey']])['password']
  when :vault
    password = ChefVault::Item.load(node[cookbook_name]['userdatabag'], node[cookbook_name]['user'])['password']
  end

  variables(
    user: node[cookbook_name]['user'],
    password: password,
    lang: node[cookbook_name]['webportal']['lang'],
    vrdeaddress: node[cookbook_name]['webportal']['vrdeaddress'],
    server_name: node[cookbook_name]['webportal']['server_name']
  )
end

node[cookbook_name]['webportal']['additionnal_websites'].each do |website, website_config|
  apache2_default_site website do
    default_site_name website
    website_config.each do |setting, value|
      send(setting, value)
    end
  end
end

service 'apache2' do
  service_name apache_platform_service_name
  supports restart: true, status: true, reload: true
  action :enable
end

service 'apache2' do
  service_name apache_platform_service_name
  supports restart: true, status: true, reload: true
  action :restart
end
