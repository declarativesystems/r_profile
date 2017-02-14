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
end
