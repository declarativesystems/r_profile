require 'spec_helper'

describe 'r_profile::motd' do
  let(:facts) do
    {
      :kernel   => "Linux",
      :osfamily => "RedHat",
    }
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
    it { should contain_file('/etc/motd').with(
      {
        :owner => 'root',
        :group => 'root',
        :mode  => '0644',
      }
    )}
  end

  context 'correct permissions on AIX' do
    let :facts do
      {
        :kernel => "AIX",
        :os => {
          :family => "AIX"
        }
      }
    end
    let :params do
      {
        :content => "hello, world",
      }
    end
    it { should contain_file('/etc/motd').with(
      {
        :owner => 'bin',
        :group => 'bin',
        :mode  => '0644',
      }
    )}
  end

end
