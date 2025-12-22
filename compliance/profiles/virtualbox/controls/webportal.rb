# Cookbook:: virtualbox

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

control 'virtualbox_webportal_control' do
  impact 0.7
  title 'Virtualbox Webportal Control'
  desc 'This is the control for Virtualbox Webportal'

  describe apache_conf do
    its('User') { should cmp 'www-data' }
    its('Listen') { should =~ [ '80', '443' ] }
  end

  describe http('http://localhost:8080/phpvirtualbox') do
    its('status') { should cmp 200 }
  end
end
