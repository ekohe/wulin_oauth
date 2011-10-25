require 'test_helper'

class DefaultRoutingTest < ActionController::TestCase
  def setup
    @routes = Rails.application.routes
  end
  
  def assert_named_route(result, *args)
    assert_equal result, @routes.url_helpers.send(*args)
  end
  
  test 'map new user session' do
    assert_recognizes({:controller => 'wulin_oauth/user_sessions', :action => 'new'}, {:path => 'login', :method => :get})
    assert_named_route "/login", :login_path
  end

  test 'map create user session' do
    assert_recognizes({:controller => 'wulin_oauth/user_sessions', :action => 'create'}, {:path => 'login', :method => :post})
    assert_named_route "/login", :login_path
  end

  test 'map destroy user session' do
    assert_recognizes({:controller => 'wulin_oauth/user_sessions', :action => 'destroy'}, {:path => 'logout', :method => :get})
    assert_named_route "/logout", :logout_path
  end
end
