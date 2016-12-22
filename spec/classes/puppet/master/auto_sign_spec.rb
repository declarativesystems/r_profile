require 'spec_helper'
describe 'r_profile::puppet::master::auto_sign' do
  context 'with default values for all parameters' do
    it {
      should contain_class('r_profile::puppet::master::auto_sign')
    }
  end
  context 'autosign disabled removes autosigning' do
    let :params do
      {
        :ensure => 'absent',
      }
    end
    it {
      should contain_class('r_profile::puppet::master::auto_sign')
      should contain_file("autosign_conf").with({
        'ensure' => 'absent',
      })
      should contain_ini_setting("puppet_conf_autosign_script").with({
        'ensure' => 'absent',
      })
    }
  end

  context 'autosign accept_all creates autosign_conf' do
    let :params do
      {
        :ensure => 'accept_all',
      }
    end
    it {
      should contain_class('r_profile::puppet::master::auto_sign')
      should contain_file("autosign_conf").with({
        'ensure' => 'present',
      })
      should contain_ini_setting("puppet_conf_autosign_script").with({
        'ensure' => 'absent',
      })
    }
  end

  context 'autosign policy creates autosign_conf' do
    let :params do
      {
        :ensure => 'policy',
        :secret => 'aaaaaaaa'
      }
    end
    it {
      should contain_class('r_profile::puppet::master::auto_sign')
      should contain_file("autosign_conf").with({
        'ensure' => 'absent',
      })
      should contain_ini_setting("puppet_conf_autosign_script").with({
        'ensure' => 'present',
      })
    }
  end
end
