#
# Cookbook Name:: virtualbox-install
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

vbox_package_name = "Oracle VM VirtualBox #{node['virtualbox']['version']}-#{node['virtualbox']['releasever']}"

case node['platform_family']
when 'mac_os_x'

  sha256sum = vbox_sha256sum(node['virtualbox']['url'])

  dmg_package vbox_package_name do
    source node['virtualbox']['url']
    checksum sha256sum
    type 'pkg'
  end

when 'windows'

  sha256sum = vbox_sha256sum(node['virtualbox']['url'])
  win_pkg_version = node['virtualbox']['version']
  Chef::Log.debug("Inspecting windows package version: #{win_pkg_version.inspect}")

  windows_package vbox_package_name do
    action :install
    source node['virtualbox']['url']
    checksum sha256sum
    installer_type :custom
    options "-s"
  end

when 'debian'
  package %w(libvpx5 libsdl1.2debian libcaca0 libxkbcommon-x11-0 libpulse0 libasyncns0 libsndfile1 libflac8 libqt5x11extras5 libqt5widgets5 libqt5printsupport5 libqt5opengl5 libqt5gui5 libqt5dbus5 libqt5network5 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 libqt5core5a libdouble-conversion1 ) do
     action :install
  end
  remote_file '/tmp/virtualbox.deb' do
    source node['virtualbox']['url']
    action :create
  end
  dpkg_package vbox_package_name do
    action :install
    source "/tmp/virtualbox.deb"
  end
  package 'dkms'

when 'rhel', 'fedora', 'opensuse'
  rpm_package vbox_package_name do
    action :install
    source node['virtualbox']['url']
  end
end

remote_file "/tmp/#{node['virtualbox']['ext_pack_name']}" do
  source node['virtualbox']['ext_pack_url']
  action :create
end
execute 'Install Oracle VM VirtualBox Extension Pack' do
  command "echo 'y' | /usr/bin/vboxmanage extpack install /tmp/#{node['virtualbox']['ext_pack_name']}"
end
