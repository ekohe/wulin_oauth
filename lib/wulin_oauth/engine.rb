# frozen_string_literal: true

require "rails"
require "wulin_oauth/controller"

module WulinOAuth
  class Engine < ::Rails::Engine
    engine_name :wulin_oauth

    initializer "add assets to precompile" do |app|
      if defined?(Propshaft)
        app.config.assets.paths << root.join("app", "assets", "images")
      else
        app.config.assets.precompile += %w[wulin_oauth.js wulin_oauth.css indicator.gif]
      end
    end

    initializer "wulin_oauth.current_user" do
      # :action_controller_base, not :action_controller — the latter also fires
      # for ActionController::API, which has no helper_method.
      ActiveSupport.on_load(:action_controller_base) do
        include WulinOAuth::AbstractController
        include WulinOAuth::Controller
      end
    end

    # Here rather than when this file is required: by the time initializers run, Bundler has required
    # every gem, so the menu does not depend on wulin_master coming before wulin_oauth in the Gemfile.
    initializer "wulin_oauth.app_bar_menu" do
      require "wulin_oauth/wulin_master" if defined?(::WulinMaster)
    end
  end
end
