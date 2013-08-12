require 'wulin_oauth'
require 'rails'
require 'action_controller'

module WulinOAuth
  class Engine < ::Rails::Engine
    initializer "add assets to precompile" do |app|
       app.config.assets.precompile += %w( wulin_oauth.js wulin_oauth.css )
    end
  end
end