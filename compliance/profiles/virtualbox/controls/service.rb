# Cookbook:: virtualbox

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

control 'virtualbox_service_control' do
  impact 0.7
  title 'Virtualbox Service Control'
  desc 'This is the control for Virtualbox Service'

  describe user('vbox') do
    it { should exist }
  end
  
  describe service('vboxautostart-service') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
