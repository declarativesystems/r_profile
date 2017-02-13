require 'spec_helper'
describe 'r_profile::puppet::master::agent_installers' do
  # dummy PE provided type - to prevent compile error (alternative would be to
  # mock)
  let :pre_condition do
    'define pe_staging::file($timeout=0) {}'
  end

  context "catalog compiles" do
    it { should compile}
  end
  
  context 'with default values for all parameters' do
    it {
      should contain_class('r_profile::puppet::master::agent_installers')
    }
  end
end
