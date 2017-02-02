require 'spec_helper'
describe 'r_profile::lockdown::at' do
  let :facts do
    {
      :os => {
        :family => 'RedHat',
      }
    }
  end

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

  context 'manages correct files on solaris' do
    let :facts do
      {
        :os => {
          :family => 'Solaris',
        }
      }
    end
    let :params do
      {
        :ensure => true,
      }
    end
    it { should contain_file('/etc/cron.d/at.allow')}
    it { should contain_file('/etc/cron.d/at.deny')}
    it { should contain_file_line('/etc/cron.d/at.allow_user_root').with(
      {
        :ensure => 'present',
        :path   => '/etc/cron.d/at.allow',
        :line   => 'root',
      }
    )}
  end

  context 'manages correct files on aix' do
    let :facts do
      {
        :os => {
          :family => 'Aix',
        }
      }
    end
    let :params do
      {
        :ensure => true,
      }
    end
    it { should contain_file('/var/adm/cron/at.allow')}
    it { should contain_file('/var/adm/cron/at.deny')}
    it { should contain_file_line('/var/adm/cron/at.allow_user_root').with(
      {
        :ensure => 'present',
        :path   => '/var/adm/cron/at.allow',
        :line   => 'root',
      }
    )}
  end

end
