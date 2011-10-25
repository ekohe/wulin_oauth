require 'test_helper'
require 'models/wulin_oauth/user'
require 'load_schema'

class UserTest < ActiveSupport::TestCase
  load_schema
    
  # Replace this with your real tests.
  test "test schema has loaded correctly" do
    assert_equal [], WulinOAuth::User.all
  end
  
  test 'validations are applied' do
    validators = WulinOAuth::User.validators_on :login
    presence = validators.find{ |v| v.kind == :presence }
    uniqueness = validators.find{ |v| v.kind == :uniqueness }
    assert_not_equal false, presence.options[:with]
    assert_not_equal false, uniqueness.options[:with]
  end
end