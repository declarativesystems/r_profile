require 'spec_helper'
describe 'r_profile::lockdown::user' do
  context 'with default values for all parameters' do
    it { should contain_class('r_profile::lockdown::user') }
  end

  context 'disable the password of passed in users' do
    users = ['curly', 'larry', 'moe']
    let :params do
      {
        :disable_password => users
      }
    end
    users.each { |user|
      it { should contain_user(user).with({:password => '*'})}
    }
  end

  context 'disable the shell of passed in users' do
    users = ['curly', 'larry', 'moe']
    let :params do
      {
        :disable_shell => users
      }
    end
    users.each { |user|
      it { should contain_user(user).with({:shell => '/usr/bin/false'})}
    }
  end

  context 'remove the passed in users' do
    users = ['curly', 'larry', 'moe']
    let :params do
      {
        :delete => users
      }
    end
    users.each { |user|
      it { should contain_user(user).with({:ensure => 'absent'})}
    }
  end

  context 'disable shell and/or password for users' do
    let :params do
      {
        :disable_password => ['curly', 'larry'],
        :disable_shell    => ['larry', 'moe'],
      }
    end
    it { should contain_user('curly').with(
      {:password => '*', :shell => nil})
    }
    it { should contain_user('larry').with(
      {:password => '*', :shell => '/usr/bin/false'})
    }
    it { should contain_user('moe').with(
      {:password => nil, :shell => '/usr/bin/false'})
    }
  end

  context 'disable shell and password on user being removed is an error' do
    users = ['curly', 'larry', 'moe']
    let :params do
      {
        :disable_password => users,
        :disable_shell    => users,
        :delete           => users
      }
    end
    it {
      expect {is_expected.to compile}.to raise_error(/Duplicate declaration/)
    }
  end

end
