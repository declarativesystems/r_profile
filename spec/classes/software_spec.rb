require 'spec_helper'
describe 'r_profile::software' do
  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::software') }
  end

  context "packages specified" do
    let :params do
      {
        :packages => {
          "foo" => {}
        }
      }
    end
    it { should contain_package('foo') }
  end

end
