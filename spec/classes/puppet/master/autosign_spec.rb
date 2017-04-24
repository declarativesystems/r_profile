require 'spec_helper'
describe 'r_profile::puppet::master::autosign' do
  let :pre_condition do
    'service { "pe-puppetserver": }'
  end

  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it {
      should contain_class('r_profile::puppet::master::autosign')
    }
  end
  context 'autosign disabled removes autosigning' do
    let :params do
      {
        :ensure => 'absent',
      }
    end
    it {
      should contain_class('r_profile::puppet::master::autosign')
      should contain_ini_setting("puppet_conf_autosign_script").with({
        'value' => false,
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
      should contain_class('r_profile::puppet::master::autosign')
      should contain_ini_setting("puppet_conf_autosign_script").with({
        'value' => true,
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
      should contain_class('r_profile::puppet::master::autosign')
      should contain_file("autosign_conf").with({
        'ensure' => 'absent',
      })
      should contain_ini_setting("puppet_conf_autosign_script").with({
        'value' => '/usr/local/bin/puppet_enterprise_autosign.sh',
      })
    }
  end
end
