require 'spec_helper'
describe 'r_profile::linux::selinux' do
  let :facts do
      {
        :operatingsystemmajrelease  => '7',
        :osfamily                   => 'RedHat',
        :operatingsystem            => 'CentOS',
        :selinux                    => true,
      }
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::linux::selinux') }
  end

  context 'does not reconfigure SELinux by default' do
    it { should_not contain_class('selinux')}
  end

  context 'sets permissive mode when requested' do
    let :params do
      {
        :sel_mode => 'permissive',
      }
    end
    it { should contain_class('selinux').with(
      {
        :mode => 'permissive',
      }
    )}
  end

  context 'sets enforcing mode when requested' do
    let :params do
      {
        :sel_mode => 'enforcing',
      }
    end
    it { should contain_class('selinux').with(
      {
        :mode => 'enforcing',
      }
    )}
  end

  context 'sets disabled mode when requested' do
    let :params do
      {
        :sel_mode => 'disabled',
      }
    end
    it { should contain_class('selinux').with(
      {
        :mode => 'disabled',
      }
    )}
  end

  context 'removes setroubleshoot package when requested' do
    let :params do
      {
        :remove_troubleshoot => true,
      }
    end
    it { should contain_package('setroubleshoot').with(
      {
        :ensure => 'absent',
      }
    )}
  end

  context 'leaves setroubleshoot alone unless requested' do
    it { should_not contain_package('setroubleshoot').with(
      {
        :ensure => 'absent',
      }
    )}
  end


end
