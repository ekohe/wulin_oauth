require 'ostruct'

class User
  # Creates a user from the code coming after the oauth login
  def self.get_access_token(code)
    return nil if code.nil? # Return nil if there's no code
    
    response = HTTParty.post(WulinOAuth.access_token_url, :body => {
      :client_id => WulinOAuth.oauth_identifier, 
      :client_secret => WulinOAuth.oauth_secret, 
      :redirect_uri => WulinOAuth.redirect_uri, 
      :code => code,
      :grant_type => 'authorization_code'}
    )
    
    return nil if response["access_token"].nil? # Returns nil if there's no access token
    
    access_token = response["access_token"]
    user_info = ActiveSupport::JSON.decode(HTTParty.get(WulinOAuth.resource_host + '/users/me.json', :query => {:oauth_token => access_token}).body)
    new_user = self.new(HashWithIndifferentAccess.new(response.merge(user_info)))
    return nil if new_user.id.nil? # Returns nil if there is no id associated to the user
    
    new_user
  end

  # Creates a user from session data
  def self.from_session(session)
    if session[:user].nil?
      nil
    else
      self.new(session[:user])
    end
  end
  
  attr_accessor :id, :email, :access_token, :expire_at, :refresh_token, :level
  
  def initialize(attributes={})
    self.id = attributes[:id]
    self.email = attributes[:email]
    self.access_token = attributes[:access_token]
    self.refresh_token = attributes[:refresh_token]
    self.level = attributes[:level].to_sym if attributes[:level]
    self.expire_at = Time.now + attributes[:expires_in].to_i if attributes[:expires_in]
    self.expire_at = Time.at(attributes[:expire_at].to_i) if attributes[:expire_at]
  end
  
  def to_hash
    {:id => self.id,
     :email => self.email,
     :access_token => self.access_token,
     :refresh_token => self.refresh_token,
     :expire_at => self.expire_at,
     :level => self.level}
  end
  
  def admin?
    self.level == :administrator
  end
  
  class << self
    def reflections
      {}
    end
    
    def table_name
      "users"
    end
    
    def column_names
      %w(email)
    end
    
    def columns
      [OpenStruct.new({:name => :email})]
    end
    
    [:order, :limit, :offset, :includes, :joins, :where].each do |method|
      define_method method do |args|
        # Don't do anything, because we are passing by the complete URL anyway.
        self
      end
    end

    def set_current_user(user)
      Thread.current[:user] = user
      self
    end
    
    def current_user
      Thread.current[:user]
    end
    
    def set_request_uri(uri)
      @request_uri = uri
      self
    end

    def all
      self.to_a
    end
    
    def to_a
      return [] unless current_user && @request_uri
      url = WulinOAuth.resource_host + @request_uri +
            "&invited_users_only=true" +
            "&oauth_token=" + current_user.access_token 
      users = ActiveSupport::JSON.decode(HTTParty.get(url).body)
      @count = users["total"].to_s
      return [] unless users["rows"]
      # users["rows"].collect{|attributes| User.new(HashWithIndifferentAccess.new(attributes.inject({}){|a,b| a.merge(b)})) }
      users["rows"].collect do |attrs|
        User.new({id: attrs[0], email: attrs[1], level: attrs[2]})
      end
    end
    
    def count
      @count
    end
  end
end