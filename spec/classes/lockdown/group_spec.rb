require 'spec_helper'
describe 'r_profile::lockdown::group' do
  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::lockdown::group') }
  end

  context 'removes the correct groups' do
    groups = ['curly', 'larry', 'moe']
    let :params do
      {
        :delete => groups
      }
    end
    groups.each { |group|
      it { should contain_group(group).with({:ensure => 'absent'})}
    }
  end

end
