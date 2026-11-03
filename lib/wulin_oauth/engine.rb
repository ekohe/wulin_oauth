# frozen_string_literal: true

require "rails"
require "wulin_oauth/controller"

module WulinOAuth
  class Engine < ::Rails::Engine
    engine_name :wulin_oauth

    # Extensions to wulin_permits' UsersController and UserGrid, applied each time Zeitwerk loads one
    # of them -- including after a reload, and never at boot. They live outside the autoloaded
    # directories because a gem file at the same relative path as wulin_permits' would shadow it, and
    # which engine won would depend on load order. Loading them at boot would load UsersController,
    # whose WulinMaster::ScreenController calls the host's ApplicationController.define_menu: a
    # generator or a rake task run before the app has one would fail.
    overrides = root.join("app", "overrides")
    OVERRIDES = {
      "UsersController" => overrides.join("users_controller_override.rb").to_s,
      "UserGrid" => overrides.join("user_grid_override.rb").to_s
    }.freeze

    # In an initializer, not the class body: from Rails 8.1 Rails.autoloaders is the application's,
    # and there is none yet when Bundler requires this file. The main autoloader is set up in the
    # Finisher, after every engine's initializers.
    initializer "wulin_oauth.overrides" do |app|
      app.autoloaders.main.ignore(overrides.to_s)
      OVERRIDES.each do |cpath, override|
        app.autoloaders.main.on_load(cpath) { load override }
      end
    end

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
