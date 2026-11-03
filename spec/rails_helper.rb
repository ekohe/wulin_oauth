# frozen_string_literal: true

require "spec_helper"
require "rails"
require "action_controller/railtie"
require "active_model/railtie"
require "haml-rails"
require "tmpdir"

require_relative "support/wulin_master"

# The host app always provides this; the gem's controllers inherit from it, and its before_action is
# what UserSessionsController's own actions skip.
class ApplicationController < ActionController::Base
  before_action :require_login
end

require "wulin_oauth"

# There is no database and no ActiveRecord model to boot a full dummy app for, so this is the smallest
# Rails::Application that gives real routing and a real ActionController::Base: config.root is an empty
# tmp dir, so the only routes drawn are the engine's.
class TestApp < Rails::Application
  config.root = Dir.mktmpdir
  config.eager_load = false
  config.secret_key_base = "test"
  config.hosts.clear
  config.logger = Logger.new(IO::NULL)

  # The engine adds its Sprockets manifests to config.assets.precompile when Propshaft is absent.
  config.assets = ActiveSupport::OrderedOptions.new
  config.assets.precompile = []
end

Rails.application.initialize!

require "rspec/rails"

RSpec.configure do |config|
  # Tests set only the keys they need, rather than reading config/wulin_oauth.yml.
  config.before { WulinOAuth.configuration = {} }

  config.before do
    Thread.current[:user] = nil
    Thread.current[:all] = nil
  end
end
