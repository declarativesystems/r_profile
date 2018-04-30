require 'spec_helper'
describe 'r_profile::linux::audit' do
  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::linux::audit') }
  end

  context 'does not install package if params say not to' do
    let :params do
      {
        :manage_package => false,
      }
    end
    it { should_not contain_package('audit') }
  end

  context 'installs package by default' do
    it { should contain_package('audit') }
  end

  context 'manages the service by default' do
    it { should contain_service('auditd') }
  end

  context 'does not manage service when params say not to' do
    let :params do
      {
        :manage_service => false,
      }
    end
    it { should_not contain_service('auditd') }
  end

  context 'does not set rules when list empty' do
    it { should_not contain_file('/etc/audit/audit.rules') }
  end

  context 'sets rules when list set' do
    let :params do {
      :rules => "hello, world",
    }
    end
    it { should contain_file('/etc/audit/audit.rules') }
  end

  context 'refreshes service on rule change by default' do
    let :params do {
      :rules => "hello, world",
    }
    end
    it { should contain_file('/etc/audit/audit.rules').that_notifies('Exec[refresh_auditd]')}
  end

  context 'does not refresh service on rule change when params say not to' do
    let :params do {
      :rules                => "hello, world",
      :refresh_after_rules  => false,
    }
    end
    it { should contain_file('/etc/audit/audit.rules').with(
      {
        :notify => nil,
      }
    )}
  end

end
