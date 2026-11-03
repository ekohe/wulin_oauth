# frozen_string_literal: true

require "spec_helper"
require "rails"
require "action_controller/railtie"
require "active_model/railtie"
require "haml-rails"

require_relative "support/wulin_master"

# The host app always provides this; the gem's controllers inherit from it, and its before_action is
# what UserSessionsController's own actions skip.
class ApplicationController < ActionController::Base
  before_action :require_login
end

require "wulin_oauth"

# There is no database and no ActiveRecord model to boot a full dummy app for, so this is the smallest
# Rails::Application that gives real routing and a real ActionController::Base. Its root,
# spec/fixtures/host_app, has no routes of its own -- the only ones drawn are the engine's -- and
# stands in for wulin_permits' UsersController and UserGrid, which the engine's overrides extend.
class TestApp < Rails::Application
  config.root = File.expand_path("fixtures/host_app", __dir__)
  config.eager_load = false
  config.secret_key_base = "test"
  config.hosts.clear
  config.logger = Logger.new(IO::NULL)
end

Rails.application.initialize!

# Read before any example can autoload them: booting must not load the classes the overrides extend.
LOADED_AT_BOOT = %i[UsersController UserGrid].reject { |name| Object.autoload?(name) }.freeze

require "rspec/rails"

RSpec.configure do |config|
  # Tests set only the keys they need, rather than reading config/wulin_oauth.yml.
  config.before { WulinOAuth.configuration = {} }

  config.before do
    Thread.current[:user] = nil
    Thread.current[:all] = nil
  end
end
