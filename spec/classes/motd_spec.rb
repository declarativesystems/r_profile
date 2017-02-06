require 'spec_helper'

describe 'r_profile::motd' do
  let(:facts) do
    {
      :kernel   => "Linux",
      :osfamily => "RedHat",
    }
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::motd') }
  end
end
