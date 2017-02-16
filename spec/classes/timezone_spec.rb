require 'spec_helper'
describe 'r_profile::timezone' do
  let(:facts) do
    {
      :os => {
        "family" => "RedHat",
        "release" => {
          "major" => "6",
        }
      }
    }
  end
  context "catalog compiles" do
    it { should compile}
  end
  context 'with default values for all parameters' do
    it { should contain_class('r_profile::timezone') }
  end
end
