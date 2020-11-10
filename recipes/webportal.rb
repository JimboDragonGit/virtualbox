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
include_recipe "#{cookbook_name}::webservice"

# This recipe requires the apache2 cookbook to be available
# include_recipe "apache2"
# include_recipe "apache2::mod_php5"

apache2_install "virtualbox-apache2" do
  apache_user node['virtualbox']['user']
  apache_group node['virtualbox']['group']
  mpm "prefork"
  docroot_dir File.dirname node['virtualbox']['webportal']['installdir']
end
service 'apache2' do
  action :nothing
end
apache2_mod_php "virtualbox-apache2"

package ['php-xml', 'php-soap', 'php-json']

directory node['virtualbox']['webportal']['installdir'] do
  user node['virtualbox']['user']
  group node['virtualbox']['group']
  recursive true
end

git node['virtualbox']['webportal']['installdir'] do
  repository "https://github.com/phpvirtualbox/phpvirtualbox.git"
  action :sync
  checkout_branch 'develop'
  enable_checkout false
  user node['virtualbox']['user']
  group node['virtualbox']['group']
end

directory "#{node['virtualbox']['webportal']['installdir']}/.git" do
  action :delete
  recursive true
end

template "#{node['virtualbox']['webportal']['installdir']}/config.php" do
  source "config.php.erb"
  mode "0644"
  notifies :restart, "service[vboxweb-service]", :immediately
  notifies :restart, "service[apache2]", :immediately
  variables(
      :password => data_bag_item('passwords','virtualbox-user')['password']
  )
end
