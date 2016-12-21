require 'spec_helper'
describe 'r_profile::puppet::master::proxy' do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7.2.1511',
      :virtual                => true,
      :is_pe                  => true,
      :pe_version             => '2016.4.2',
    }
  end
  describe 'disables proxy when unset' do
    it {
      should contain_class('r_profile::puppet::master::proxy')
      should contain_ini_setting("puppet.conf http_proxy_host").with({
        'ensure' => 'absent'
      })
      should contain_ini_setting("puppet.conf http_proxy_port").with({
        'ensure' => 'absent'
      })
      should contain_file_line("pe-puppetserver http_proxy")
      should contain_file_line("pe-puppetserver https_proxy")
    }
  end

  describe 'enables proxy when set' do
    let :params do
      {
        :proxy => 'http://proxy.the.world:8080',
      }
    end
    it {
      should contain_class('r_profile::puppet::master::proxy')
      should contain_ini_setting("puppet.conf http_proxy_host").with({
        'ensure' => 'present'
      })
      should contain_ini_setting("puppet.conf http_proxy_port").with({
        'ensure' => 'present'
      })
      should contain_file_line("pe-puppetserver http_proxy")
      should contain_file_line("pe-puppetserver https_proxy")
    }
  end
end
