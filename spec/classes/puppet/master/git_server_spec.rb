require 'spec_helper'
describe 'r_profile::puppet::master::git_server' do
  # dummy/mocks for whatsaranjit-node_manager.  Can't use the real module
  # since it starts looking for server config files on the system under test
  # working around this with fakefs is overkill
  before(:each) do
    Puppet::Parser::Functions.newfunction(:node_groups, :type => :rvalue) { |args|
      {'PE Master' => { 'classes' => {}}}
    }
  end
  let :pre_condition do
    '
    class sshkeys(){}
    define sshkeys::install_keypair($ensure, $ssh_dir,){}
    define sshkeys::known_host($ssh_dir) {}
    define sshkeys::authorize($ensure, $authorized_keys, $ssh_dir){}
    '
  end

  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it {
      should contain_class('r_profile::puppet::master::git_server')
    }
  end
end
