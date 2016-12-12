require 'spec_helper'

describe 'r_profile::linux::ntp', :type => :class do
  on_supported_os.select { |_, f| f[:os]['family'] != 'Solaris' }.each do |os, f|
    context "on #{os}" do
      let(:facts) do
        f
      end

      it { is_expected.to compile.with_all_deps }

      context "default usage" do
        it { is_expected.to contain_class('ntp') }
      end

      context "no ntp on docker" do
        let :facts do
          f.merge({
            :virtual => 'docker'
          })
        end
        it { is_expected.not_to contain_class('ntp') }
      end

      context "server parameter passed correctly" do
        server_array = [ 'a.b.c', 'd.e.f']
        let :params do 
          {
            :servers => server_array
          }
        end
        it { is_expected.to contain_class('ntp').with_servers(server_array) }
      end

      context "no ntp package if not managing package" do
        let :params do
          {
            :package_manage => false
          }
        end
        it { is_expected.not_to contain_package('ntp') }
      end

      context "ntp package if managing package" do
        let :params do
          {
            :package_manage => true
          }
        end
        it { is_expected.to contain_package('ntp') }
      end

      context "no ntp service if not managing service" do
        let :params do
          {
            :service_manage => false
          }
        end
        it { is_expected.not_to contain_service('ntp') }
      end

      context "ntp service if managing service" do
        let :params do
          {
            :service_manage => true
          }
        end
        it { is_expected.to contain_service('ntp') }
      end
    end
  end
end
