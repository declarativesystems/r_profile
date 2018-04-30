require 'spec_helper'
describe 'r_profile::linux::mounts' do
  let :facts do
    {
      :mountpoints => {
        "/tmp"      => {
          "filesystem" => "foo",
        },
        "/dev/shm"  => {
          "filesystem" => "bar",
        },
      }
    }
  end
  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::linux::mounts') }
  end
end
