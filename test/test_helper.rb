ENV['RAILS_ENV'] = 'test'

$:.unshift File.dirname(__FILE__)

require "action_controller/railtie"
require "active_record"

require "rails/test_unit/railtie"
require "rails/test_help"

require 'wulin_oauth' 

# create a dummy rails app
class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
end
Rails.application = TestApp

class ApplicationController < ActionController::Base
end

module Rails
  def self.root
    @root ||= File.expand_path("../../tmp/rails", __FILE__)
  end
end
Rails.application.config.root = Rails.root

# includes routes
require 'routes'

# for generators
require "rails/generators/test_case"