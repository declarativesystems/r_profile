require 'spec_helper'
describe 'r_profile::user' do
  context "catalog compiles" do
    it { should compile}
  end

  context 'with default values for all parameters' do
    it { should contain_class('r_profile::user') }
  end

  context 'manages users' do
    let :params do
      {
        :users => {
          "bob" => {},
        }
      }
    end
    it { should contain_user('bob')}
  end


  context 'manages users' do
    let :params do
      {
        :groups => {
          "foo" => {},
        }
      }
    end
    it { should contain_group('foo')}
  end

end
