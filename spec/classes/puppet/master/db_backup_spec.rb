require 'spec_helper'
describe 'r_profile::puppet::master::db_backup' do
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
      should contain_class('r_profile::puppet::master::db_backup')
      should contain_cron('pe_database_backups').with({
        'ensure' => 'present'
      })
    }
  end

  context 'with default values for all parameters' do
    let :params do
      {
        'ensure' => 'absent'
      }
    end
    it {
      should contain_class('r_profile::puppet::master::db_backup')
      should contain_cron('pe_database_backups').with({
        'ensure' => 'absent'
      })
    }
  end
end
