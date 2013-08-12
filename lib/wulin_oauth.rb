module WulinOAuth
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'application_controller'

  def self.configuration
    @configuration ||= YAML.load(File.read(File.join(Rails.root, 'config', 'wulin_oauth.yml')))[Rails.env]
    @configuration
  end
  
  def self.oauth_identifier
    configuration['oauth_identifier']
  end
  
  def self.oauth_secret
    configuration['oauth_secret']
  end
  
  def self.redirect_uri
    configuration['redirect_uri']
  end
  
  def self.resource_host
    configuration['resource_host']
  end
  
  def self.access_token_url
    "#{configuration['access_token_uri']}?client_id=#{self.oauth_identifier}&redirect_uri=#{self.redirect_uri}"
  end
  
  def self.new_authorization_url(options={})
    url = "#{configuration['authorize_uri']}?client_id=#{self.oauth_identifier}&redirect_uri=#{self.redirect_uri}"
    url += "&reset_session=true" if options[:reset_session]
    url
  end
end
