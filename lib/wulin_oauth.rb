module WulinOAuth
  require 'wulin_oauth/engine' if defined?(Rails) && Rails::VERSION::MAJOR >= 5
  require 'application_controller'

  def self.configuration
    @configuration ||= YAML.load(File.read(File.join(Rails.root, 'config', 'wulin_oauth.yml')))[Rails.env]
    @configuration
  end

  def self.configuration=(new_configuration)
    @configuration = new_configuration
  end

  def self.oauth_identifier
    configuration['oauth_identifier']
  end

  def self.oauth_secret
    configuration['oauth_secret']
  end

  def self.change_password_uri
    configuration['change_password_uri']
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

  def self.new_authorization_url(options = {})
    url = "#{configuration['authorize_uri']}?client_id=#{self.oauth_identifier}&redirect_uri=#{self.redirect_uri}"
    url += '&reset_session=true' if options[:reset_session]
    url
  end
end

if defined? WulinMaster
  WulinMaster::AppBarMenu.menus.add_menu(:user_menu,
    icon: :account_circle,
    label: -> { current_user&.email },
    class: "dropdown-trigger",
    data: { target: "user_menu-list" },
    order: 1000
  ) do |sub_menu|
    sub_menu.add_menu(:change_password, label: 'Change Password', icon: :lock, order: 1, url: -> { WulinOAuth.change_password_uri }, target: :_blank)
    sub_menu.add_menu(:logout, label: 'Logout', icon: :eject, order: 1000, url: -> { "#{WulinOAuth.configuration['logout_uri']}?redirect_uri=#{logout_url}" })
  end
end