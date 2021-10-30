require 'open-uri'
require 'uri'

module Vbox
  module Helpers

    include Apache2::Cookbook::Helpers

    # Retrieves the SHA256 checksum from the VirtualBox downloads
    # site's list of checksums.
    def vbox_sha256sum(url)
      filename = File.basename(URI.parse(url).path)
      urlbase = url.gsub("#{filename}", "")
      sha256sum = ""
      URI.open("#{urlbase}/SHA256SUMS").each do |line|
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

    def segment_version
      gem_version = Gem::Version.new(node['virtualbox']['version']).segments
      if gem_version.count > 3
        Chef::Application.fatal("node['virtualbox']['version'] must have maximum of 3 dots")
      end
      major = gem_version[0]
      feature = gem_version[1] || 0
      bugfix = gem_version[2] || 0

      [major, feature, bugfix]
    end

    def file_url_version
      vbox_version = segment_version

      vboxversion = "#{vbox_version[0]}.#{vbox_version[1]}_#{vbox_version[0]}.#{vbox_version[1]}.#{vbox_version[2]}"
      case node['platform_family']
      when 'solaris', 'mac_os_x', 'windows'
        vboxversion = "VirtualBox-#{vbox_version.join('.')}-#{node['virtualbox']['releasever']}-"
      when 'debian'
        vboxversion = "virtualbox-#{vboxversion}-#{node['virtualbox']['releasever']}~#{node['lsb']['id']}~#{node['lsb']['codename']}"
      when 'rhel', 'fedora', 'suse'
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
      when 'rhel', 'fedora', 'suse'
        "-1.x86_64.rpm"
      end
    end

    def is_virtualbox_installed?
      vbox_version = segment_version[0,2].join('.')
      Chef::Log.info "Checking if package virtualbox-#{vbox_version} is installed"
      node['packages'].exist?("virtualbox-#{vbox_version}")
    end

    def is_extpack_installed?(extpack_name, version = node['virtualbox']['version'], revision = node['virtualbox']['releasever'])
      Chef::Log.info "Checking if extpack #{extpack_name} at version #{version} and revision #{revision} is installed"
      if is_virtualbox_installed?
        Chef::Log.info %x(/usr/bin/vboxmanage list extpacks | grep -A 2 '#{extpack_name}')
        true
      else
        false
      end
    end

    def default_apache_user_home
      '/var/www'
    end

    def php_version
      case node['platform_family']
      when 'debian'
        phpversion = %x(apt-cache madison #{apache_mod_php_package} | cut -d ':' -f 2 | cut -d '+' -f 1 | head -n 1)
        phpversion.chomp
      end
    end

    def php_xml_package_name
      case node['platform_family']
      when 'debian'
        "php#{php_version.chomp}-xml"
      end
    end

    def php_soap_package_name
      case node['platform_family']
      when 'debian'
        "php#{php_version.chomp}-soap"
      end
    end

    def php_json_package_name
      case node['platform_family']
      when 'debian'
        "php#{php_version.chomp}-json"
      end
    end

    def is_vbox_kernel_loaded?
      case node['platform_family']
      when 'debian'
        # lsmod | grep -q "vboxdrv[^_-]
        system("lsmod | grep vboxdrv")
      end
    end

    def get_packages_dependencies
      case node['platform_family']
      when 'mac_os_x'
      when 'windows'
      when 'debian'
        packages = %w(libsdl1.2debian libcaca0 libxkbcommon-x11-0 libpulse0 libasyncns0 libsndfile1 libflac8 libqt5x11extras5 libqt5widgets5 libqt5printsupport5 libqt5opengl5 libqt5gui5 libqt5dbus5 libqt5network5 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 libqt5core5a)
        case node['platform']
        when 'ubuntu'
          case node['platform_version']
          when '18.04'
            packages.append 'libvpx5', 'libdouble-conversion1', "libcurl4"
          when '16.04'
            packages.append 'libvpx3', 'libdouble-conversion1v5', 'libcurl3', 'libopus0', 'libxcursor1', 'libxt6'
          end
        end
        packages
      when 'rhel', 'fedora', 'suse'
      end
    end
  end
end

Chef::Node.send(:include, Vbox::Helpers)
Chef::Recipe.send(:include, Vbox::Helpers)
Chef::Resource::Execute.send(:include, Vbox::Helpers)
Chef::Resource::User.send(:include, Vbox::Helpers)
