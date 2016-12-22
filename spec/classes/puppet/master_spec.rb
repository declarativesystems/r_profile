require 'spec_helper'
describe 'r_profile::puppet::master' do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7.2.1511',
      :virtual                => true,
      :is_pe                  => true,
      :pe_version             => '2016.4.2',
      :fqdn                   => 'puppet.demo.internal',
    }
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::puppet::master') }
  end

  context 'nagios_monitored creates correct resources' do
    let :pre_condition do
      'include nagios'
    end
    let :params do
      {
        :nagios_monitored => true,
      }
    end
    it {
      should contain_class('r_profile::puppet::master')
      should contain_nagios__nagios_service_tcp('PE puppetserver')
      should contain_nagios__nagios_service_tcp('PE console')
      should contain_nagios__nagios_service_tcp('PE MCollective')
      should contain_nagios__nagios_service_tcp('PE PCP/PXP')
    }
  end

  context 'open_firewall creates firewall rules' do
    let :params do
      {
        :open_firewall => true,
      }
    end
    it {
      should contain_class('r_profile::puppet::master')
      [8140, 61613, 443, 8142].each { | port |
        should contain_firewall("100 puppet.demo.internal HTTP #{port}")
      }
    }
  end
end
