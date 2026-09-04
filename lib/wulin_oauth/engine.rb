require 'wulin_oauth'
require 'rails'
require 'action_controller'

module WulinOAuth
  class Engine < ::Rails::Engine
    initializer "add assets to precompile" do |app|
      if defined?(Propshaft)
        app.config.assets.paths << root.join("app", "assets", "images")
      else
        app.config.assets.precompile += %w( wulin_oauth.js wulin_oauth.css indicator.gif )
      end
    end
  end
end
