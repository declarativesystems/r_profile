require 'spec_helper'
describe 'r_profile' do

  context 'with defaults for all parameters' do
    it { should contain_class('r_profile') }
  end
end
