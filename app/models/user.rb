require 'ostruct'
require 'httparty'

class User
  extend ActiveModel::Naming
  class << self
    # Creates a user from the code coming after the oauth login
    def get_access_token(code)
      return nil if code.nil? # Return nil if there's no code

      response = ::HTTParty.post(WulinOAuth.access_token_url, :body => {
        :client_id => WulinOAuth.oauth_identifier,
        :client_secret => WulinOAuth.oauth_secret,
        :redirect_uri => WulinOAuth.redirect_uri,
        :code => code,
        :grant_type => 'authorization_code'}
      )

      return nil if response["access_token"].nil? # Returns nil if there's no access token

      access_token = response["access_token"]
      user_info = ActiveSupport::JSON.decode(HTTParty.get(WulinOAuth.resource_host + '/oauth/get_user/me.json', :query => {:oauth_token => access_token}).body)
      new_user = self.new(HashWithIndifferentAccess.new(response.merge(user_info)))
      return nil if new_user.id.nil? # Returns nil if there is no id associated to the user

      new_user
    end

    # Creates a user from session data
    def from_session(session)
      if session[:user].nil?
        nil
      else
        self.new(session[:user])
      end
    end

    def primary_key
      "id"
    end

    def finder_needs_type_condition?
      false
    end

    def reflections
      {}
    end

    def table_name
      "users"
    end

    def column_names
      %w(email)
    end

    def human_attribute_name(column)
      {
        email: 'Email'
      }[column.to_sym]
    end

    def find(id)
      if Array === id
        all.select{|x| x.id.to_i == id.to_i}
      else
        all.find{|x| x.id.to_i == id.to_i}
      end
    end

    def columns
      [OpenStruct.new({:name => :email})]
    end

    %w(order limit offset includes joins where).each do |method_name|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method_name}(*args)
          self
        end
      RUBY
    end

    # #map flatten uniq join
    %w(map uniq flatten join).each do |method_name|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method_name}(*args)
          all
        end
      RUBY
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

    alias_method :scoped, :all

    def to_a(options = { invited: true })
      return [] unless current_user && @request_uri
      invited_condition = options[:invited] ? '&invited_users_only=true' : '&uninvited_users_only=true&count=20000'
      url = "#{WulinOAuth.resource_host}/users.json?#{@request_uri[12..-1]}#{invited_condition}&oauth_token=#{current_user.access_token}"
      json_text = HTTParty.get(url).body
      users = ActiveSupport::JSON.decode(json_text)
      @count = users["total"]
      return [] unless users["rows"]
      # users["rows"].collect{|attributes| User.new(HashWithIndifferentAccess.new(attributes.inject({}){|a,b| a.merge(b)})) }
      users["rows"].collect do |attrs|
        User.new({id: attrs[0], email: attrs[1], level: attrs[2], app_admin: attrs[3]})
      end
    end

    def count
      @count
    end

    def invite(user_ids)
      url = "#{WulinOAuth.resource_host}/invitations"
      json_text = HTTParty.post(url, body: {
        user_ids: user_ids,
        oauth_token: current_user.access_token
      }).body

      ActiveSupport::JSON.decode(json_text)
    end

    def remove(user_id)
      url = "#{WulinOAuth.resource_host}/invitations/#{user_id}"
      json_text = HTTParty.delete(url, body: {
        oauth_token: User.current_user.access_token
      }).body

      ActiveSupport::JSON.decode(json_text)
    end
  end


  attr_accessor :id, :ip, :email, :access_token, :refresh_token, :level, :expire_at, :expire_at, :app_admin

  def initialize(attributes={})
    self.id = attributes[:id]
    self.ip = attributes[:ip]
    self.email = attributes[:email]
    self.access_token = attributes[:access_token]
    self.app_admin = attributes[:app_admin]
    self.refresh_token = attributes[:refresh_token]
    self.level = attributes[:level].to_sym if attributes[:level]
    self.expire_at = Time.now + attributes[:expires_in].to_i if attributes[:expires_in]
    self.expire_at = Time.at(attributes[:expire_at].to_i) if attributes[:expire_at]
  end

  def to_hash
    {:id => self.id,
     :ip => self.ip,
     :email => self.email,
     :access_token => self.access_token,
     :refresh_token => self.refresh_token,
     :expire_at => self.expire_at,
     :app_admin => self.app_admin,
     :level => self.level}
  end

  def admin?
    self.level == :administrator || app_admin?
  end

  def app_admin?
    app_admin
  end
end
