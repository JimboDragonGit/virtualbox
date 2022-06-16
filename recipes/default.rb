#
# Cookbook Name:: virtualbox
# Recipe:: default
#
# Copyright 2011-2013, Joshua Timberman
# Copyright 2018, Kyle McGovern
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

vbox_package_name = "Oracle VM VirtualBox #{node[cookbook_name]['version']}-#{node[cookbook_name]['releasever']}"

vbox_sha256sum = vbox_sha256sum(node[cookbook_name]['url'])
extpack_sha256sum = vbox_sha256sum(node[cookbook_name]['ext_pack_url'])
case node['platform_family']
when 'mac_os_x'
  dmg_package vbox_package_name do
    source node[cookbook_name]['url']
    checksum vbox_sha256sum
    type 'pkg'
  end

when 'windows'
  win_pkg_version = node[cookbook_name]['version']
  Chef::Log.debug("Inspecting windows package version: #{win_pkg_version.inspect}")

  windows_package vbox_package_name do
    action :install
    source node[cookbook_name]['url']
    checksum vbox_sha256sum
    installer_type :custom
    options '-s'
  end

when 'debian'
  apt_update 'virtualbox_debian' do
    ignore_failure true
    action :update
  end

  build_essential 'Install compilation tools'

  package "linux-headers-#{node['kernel']['release']}" do
    action :install
  end

  package get_packages_dependencies do
    action :install
  end

  remote_file "#{Chef::Config[:file_cache_path]}/virtualbox.deb" do
    source node[cookbook_name]['url']
    action :create
    checksum vbox_sha256sum
  end

  dpkg_package vbox_package_name do
    action :install
    source "#{Chef::Config[:file_cache_path]}/virtualbox.deb"
  end
  package 'dkms'

  remote_file "#{::File.join(Chef::Config[:file_cache_path], node[cookbook_name]['ext_pack_name'])}" do
    source node[cookbook_name]['ext_pack_url']
    action :create
    checksum extpack_sha256sum
  end
  execute 'Install Oracle VM VirtualBox Extension Pack' do
    command "echo 'y' | /usr/bin/vboxmanage extpack install #{::File.join(Chef::Config[:file_cache_path], node[cookbook_name]['ext_pack_name'])}"
    not_if is_extpack_installed?('Oracle VM VirtualBox Extension Pack').to_s
  end

  execute 'Loading kernel' do
    command '/sbin/vboxconfig'
    not_if is_vbox_kernel_loaded?.to_s
  end

when 'rhel', 'fedora', 'suse'
  rpm_package vbox_package_name do
    checksum vbox_sha256sum
    action :install
    source node[cookbook_name]['url']
  end
end
