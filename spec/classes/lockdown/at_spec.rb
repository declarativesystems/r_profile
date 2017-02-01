require 'spec_helper'
describe 'r_profile::lockdown::at' do

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::lockdown::at') }
  end

  context 'removes/creates files when active' do
    let :params do
      {
        :ensure => true,
      }
    end
    it { should contain_file('/etc/at.allow')}
    it { should contain_file('/etc/at.deny')}
  end

  context 'leaves files alone when inactive' do
    it { should_not contain_file('/etc/at.allow')}
    it { should_not contain_file('/etc/at.deny')}
  end

end
