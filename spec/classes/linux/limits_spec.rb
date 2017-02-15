require 'spec_helper'
describe 'r_profile::linux::limits' do
  let :facts do
      {
        :operatingsystemmajrelease  => '7',
        :osfamily                   => 'RedHat',
        :operatingsystem            => 'CentOS',
        :selinux                    => true,
      }
  end

  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::linux::limits') }
  end

  context 'with settings present' do
    let :params do
      {
        :settings => {
          'root/nofile' => {
            "both" => 1048576
          }
        }
      }
    end
    it { should contain_limits__limits('root/nofile')}
  end

end
