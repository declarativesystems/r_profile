require 'spec_helper'
describe 'r_profile::dns_client' do
  let(:facts) do
    {
      :os => {
        "family" => "RedHat",
      }
    }
  end
  context "catalog compiles" do
    it { should compile}
  end
  context 'with default values for all parameters' do
    it { should contain_class('r_profile::dns_client') }
  end

  context 'does not change dns settings when no servers specified ' do
    let :params do
      {
      }
    end
    it { should_not contain_class('resolv_conf') }
  end

  context 'changes dns settings when no servers specified ' do
    let :params do
      {
        :nameservers => '1.1.1.1',
      }
    end
    it { should contain_class('resolv_conf') }
  end

  context 'changes dns settings to module defaults when asked to' do
    let :params do
      {
        :install_defaults => true,
      }
    end
    it { should contain_class('resolv_conf') }
    it { should contain_class('name_service_switch') }
  end

  context 'does not change nss settings when no keys specified ' do
    let :params do
      {
      }
    end
    it { should_not contain_class('name_service_switch') }
  end

  context 'changes nss settings when keys specified ' do
    let :params do
      {
        :nss_entries => {'hosts' => 'dns files'},
      }
    end
    it { should contain_class('name_service_switch') }
  end


end
