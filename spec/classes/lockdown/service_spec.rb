require 'spec_helper'
describe 'r_profile::lockdown::service' do
  context 'with default values for all parameters' do
    it { should contain_class('r_profile::lockdown::service') }
  end

  context 'stops and disables passed in services' do
    service_titles = ['abcd', 'efgh']
    let :params do
      {
        :services => ['abcd', 'efgh']
      }
    end
    it { should contain_service(service_titles[0]).with(
      {
        :ensure => 'stopped',
        :enable => false,
      }
    )}
    it { should contain_service(service_titles[1]).with(
      {
        :ensure => 'stopped',
        :enable => false,
      }
    )}
  end
end
