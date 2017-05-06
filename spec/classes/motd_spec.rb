require 'spec_helper'
require 'puppet_factset'

describe 'r_profile::motd' do

  let :facts do
    PuppetFactset::factset_hash('CentOS-7.0-64')
  end

  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::motd') }
  end

  context 'correct permissions on linux' do
    let :params do
      {
        :content           => "hello, world",
        :issue_content     => "hello, world",
        :issue_net_content => "hello, world",
      }
    end
    it { should contain_concat('/etc/motd').with(
      {
        :owner => 'root',
        :group => 'root',
        :mode  => '0644',
      }
    )}
  end

  context 'correct permissions on AIX' do

    let :facts do
      PuppetFactset::factset_hash('AIX-7.1-powerpc')
    end

    let :params do
      {
        :content => "hello, world",
      }
    end
    it { should contain_concat('/etc/motd').with(
      {
        :owner => 'bin',
        :group => 'bin',
        :mode  => '0644',
      }
    )}
  end

end
