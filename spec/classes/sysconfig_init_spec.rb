require 'spec_helper'
describe 'r_profile::linux::sysconfig_init' do
  context "catalog compiles" do
    it { should compile}
  end
  
  context 'with default values for all parameters' do
    it { should contain_class('r_profile::linux::sysconfig_init') }
  end

  context 'with default values for all parameters' do
    let :params do
      {
        :manage_umask  => false,
        :manage_prompt => false,
        :manage_single => false,
      }
    end
    it { should_not contain_file_line('/etc/sysconfig/init PROMPT') }
    it { should_not contain_file_line('/etc/sysconfig/init SINGLE') }
    it { should_not contain_file_line('/etc/sysconfig/init umask') }
  end
end
