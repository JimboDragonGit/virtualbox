name             'virtualbox'
maintainer       'Jimbo Dragon'
maintainer_email 'jimbo_dragon@hotmail.com'
license          'Apache 2.0'
description      'Installs virtualbox'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '4.0.0'
chef_version '>= 16.6.14'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/jimbodragon/virtualbox/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/jimbodragon/virtualbox'

%w(ubuntu debian centos redhat mac_os_x windows fedora opensuse zentyal).each do |os|
  supports os
end

depends 'apache2'
