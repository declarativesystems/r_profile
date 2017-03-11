require 'spec_helper'
describe 'r_profile::puppet::master::hiera' do
  let :pre_condition do
    'service { "pe-puppetserver": }'
  end
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7.2.1511',
      :virtual                => true,
      :is_pe                  => true,
      :pe_version             => '2016.4.2',
      :kernel                 => 'Linux',
    }
  end

  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it {
      should contain_class('r_profile::puppet::master::hiera')
    }
  end

  context 'with eyaml disabled' do
    let :params do
      {
        :eyaml => false
      }
    end
    it {
      should contain_class('r_profile::puppet::master::hiera')
    }
  end
end
