# frozen_string_literal: true

require "rails_helper"

RSpec.describe "rails g wulin_oauth:config's wulin_oauth.yml" do
  let(:config) do
    YAML.load_file(WulinOAuth::Engine.root.join("lib/generators/wulin_oauth/config/templates/wulin_oauth.yml"), aliases: true)
  end

  # Without a section, WulinOAuth.configuration is nil in that environment and /login raises.
  it "has a section for every environment, each with the provider settings" do
    %w[development test production].each do |env|
      expect(config[env]).to include("authorize_uri", "access_token_uri", "resource_host", "redirect_uri", "oauth_identifier", "oauth_secret")
    end
  end
end
