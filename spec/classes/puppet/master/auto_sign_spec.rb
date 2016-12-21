require 'spec_helper'
describe 'r_profile::puppet::master::auto_sign' do
  context 'with default values for all parameters' do
    it {
      should contain_class('r_profile::puppet::master::auto_sign')
    }
  end
end
