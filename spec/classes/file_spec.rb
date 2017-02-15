require 'spec_helper'
describe 'r_profile::file' do
  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::file') }
  end

  context 'manages files' do
    let :params do
      {
        :files => {
          "/foo" => {},
        }
      }
    end
    it { should contain_file('/foo').with(
      {
        :ensure => "file",
      }
    )}
  end

  context 'manages directories' do
    let :params do
      {
        :directories => {
          "/bar" => {},
        }
      }
    end
    it { should contain_file('/bar').with(
      {
        :ensure => "directory",
      }
    )}
  end
end
