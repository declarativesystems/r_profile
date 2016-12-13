require 'spec_helper'
describe 'r_profile::lockdown::package' do
  context 'with default values for all parameters' do
    it { should contain_class('r_profile::lockdown::package') }
  end

  context 'prurges passed in packages' do
    package_titles = ['abcd', 'efgh']
    let :params do
      {
        :packages => ['abcd', 'efgh']
      }
    end
    it { should contain_package(package_titles[0]).with(
      {
        :ensure => 'purged',
      }
    )}
    it { should contain_package(package_titles[1]).with(
      {
        :ensure => 'purged',
      }
    )}
  end
end
