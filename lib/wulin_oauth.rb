# frozen_string_literal: true

require "wulin_oauth/version"
require "wulin_oauth/engine" if defined?(Rails)
require "wulin_oauth/errors/wulin_oauth_authentication_error"
require "wulin_oauth/app_request_signer"

module WulinOAuth
  # see https://gitlab.ekohe.com/ekohe/wulin/wulin_oauth/-/merge_requests/18
  def self.configuration
    @configuration ||= begin
      YAML.load_file(
        Rails.root.join("config", "wulin_oauth.yml"), aliases: true
      )[Rails.env]
    rescue ArgumentError
      YAML.load_file(
        Rails.root.join("config", "wulin_oauth.yml")
      )[Rails.env]
    end
  end

  def self.configuration=(new_configuration)
    @configuration = new_configuration
  end

  def self.oauth_identifier
    configuration["oauth_identifier"]
  end

  def self.oauth_secret
    configuration["oauth_secret"]
  end

  def self.change_password_uri
    configuration["change_password_uri"]
  end

  def self.redirect_uri
    configuration["redirect_uri"]
  end

  def self.resource_host
    configuration["resource_host"]
  end

  def self.access_token_url
    "#{configuration["access_token_uri"]}?client_id=#{oauth_identifier}&redirect_uri=#{redirect_uri}"
  end

  def self.new_authorization_url(options = {})
    url = "#{configuration["authorize_uri"]}?client_id=#{oauth_identifier}&redirect_uri=#{redirect_uri}"
    url += "&reset_session=true" if options[:reset_session]
    url
  end
end
