require 'spec_helper'
describe 'r_profile::puppet::master::hiera' do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7.2.1511',
      :virtual                => true,
      :is_pe                  => true,
      :pe_version             => '2016.4.2',
    }
  end  
  context 'with default values for all parameters' do
    it {
      should contain_class('r_profile::puppet::master::hiera')
    }
  end
end
