require 'open-uri'
require 'uri'

module Vbox
  module Helpers

    # Retrieves the SHA256 checksum from the VirtualBox downloads
    # site's list of checksums.
    def vbox_sha256sum(url)
      filename = ::File.basename(::URI.parse(url).path)
      urlbase = url.gsub("#{filename}", "")
      sha256sum = ""
      open("#{urlbase}/SHA256SUMS").each do |line|
        sha256sum = line.split(" ")[0] if line =~ /#{filename}/
      end
      return sha256sum
    end

    # totally assumes the version is the directory in the URL where
    # the filename is. e.g.:
    # http://download.virtualbox.org/virtualbox/4.2.8/VirtualBox-4.2.8-83876-Win.exe
    # returning "4.2.8"
    def vbox_version(url)
      version = File.dirname(URI.parse(url).path).split('/').last
      return version
    end

    def file_url_version
      gem_version = Gem::Version.new(node['virtualbox']['version']).segments
      if gem_version.count > 3
        Chef::Application.fatal("node['virtualbox']['version'] must have maximum of 3 dots")
      end
      major = gem_version[0]
      feature = gem_version[1] || 0
      bugfix = gem_version[2] || 0

      vboxversion = "#{major}.#{feature}_#{major}.#{feature}.#{bugfix}"
      case node['platform_family']
      when 'solaris', 'mac_os_x', 'windows'
        vboxversion = "VirtualBox-#{node['virtualbox']['version']}-#{node['virtualbox']['releasever']}-"
      when 'debian'
        vboxversion = "virtualbox-#{vboxversion}-#{node['virtualbox']['releasever']}~#{node['lsb']['id']}~#{node['lsb']['codename']}"
      when 'rhel', 'fedora', 'opensuse'
        vboxversion = "VirtualBox-#{vboxversion}_#{node['virtualbox']['releasever']}_#{node['lsb']['id']}"
      end
      "#{vboxversion}#{platform_executable}"
    end

    #https://download.virtualbox.org/virtualbox/6.1.16/virtualbox-6.1_6.1.16-140961~Ubuntu~bionic_amd64.deb
    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1_6.1.16-140961~Ubuntu~bionic_amd64.deb
    #https://download.virtualbox.org/virtualbox/6.1.16/virtualbox-6.1_6.1.16-140961~Ubuntu~bionic_amd64.deb
    #https://download.virtualbox.org/virtualbox/6.1.16/virtualbox-6.1_6.1.16-140961~Ubuntu~eoan_amd64.deb
    #https://download.virtualbox.org/virtualbox/6.1.16/virtualbox-6.1_6.1.16-140961~Debian~buster_amd64.deb
    #https://download.virtualbox.org/virtualbox/6.1.16/virtualbox-6.1_6.1.16-140961~Debian~jessie_amd64.deb

    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1-6.1.16_140961_fedora32-1.x86_64.rpm
    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1-6.1.16_140961_fedora31-1.x86_64.rpm
    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1-6.1.16_140961_el8-1.x86_64.rpm
    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1-6.1.16_140961_el6-1.x86_64.rpm

    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1-6.1.16_140961_openSUSE150-1.x86_64.rpm
    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-SunOS.tar.gz
    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-OSX.dmg
    #https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-Win.exe

    def platform_executable
      case node['platform_family']
      when 'windows'
        "Win.exe"
      when 'solaris'
        "SunOS.tar.gz"
      when 'mac_os_x'
        "OSX.dmg"
      when 'debian'
        "_amd64.deb"
      when 'rhel', 'fedora', 'opensuse'
        "-1.x86_64.rpm"
      end
    end
  end
end

Chef::Node.send(:include, Vbox::Helpers)
Chef::Recipe.send(:include, Vbox::Helpers)
