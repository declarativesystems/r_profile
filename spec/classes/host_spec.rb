require 'spec_helper'
describe 'r_profile::host' do
  context "catalog compiles" do
    it { should compile}
  end
  context 'with default values for all parameters' do
    it { should contain_class('r_profile::host') }
  end
  context 'processes hosts entries correctly' do
    let :params do
      {
        :entries => {
          "momrah.everliving.com" => {
            "ip" => "126.126.126.126",
          }
        },
      }
    end
    it { should contain_host("momrah.everliving.com")}
  end
end
