class User
  # Creates a user from the code coming after the oauth login
  def self.get_access_token(code)
    response = HTTParty.post(WulinOAuth.access_token_url, :body => {
      :client_id => WulinOAuth.oauth_identifier, 
      :client_secret => WulinOAuth.oauth_secret, 
      :redirect_uri => WulinOAuth.redirect_uri, 
      :code => code,
      :grant_type => 'authorization_code'}
    )
    
    access_token = response["access_token"]
    user_info = HTTParty.get(WulinOAuth.resource_host + '/users/me.json', :query => {:oauth_token => access_token})    
    self.new(HashWithIndifferentAccess.new(response.merge(user_info)))
  end

  # Creates a user from session data
  def self.from_session(session)
    if session[:user].nil?
      nil
    else
      self.new(session[:user])
    end
  end
  
  attr_accessor :id, :email, :access_token, :expire_at, :refresh_token
  
  def initialize(attributes={})
    self.id = attributes[:id]
    self.email = attributes[:email]
    self.access_token = attributes[:access_token]
    self.refresh_token = attributes[:refresh_token]
    self.expire_at = Time.now + attributes[:expires_in].to_i if attributes[:expires_in]
    self.expire_at = Time.at(attributes[:expire_at].to_i) if attributes[:expire_at]
  end
  
  def to_hash
    {:id => self.id,
     :email => self.email,
     :access_token => self.access_token,
     :refresh_token => self.refresh_token,
     :expire_at => self.expire_at}
  end
end

