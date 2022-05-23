module WulinOAuth
  class WulinOauthAuthenticationError < StandardError
    def initialize(msg = "Authorization to application portal expired. Please log out and log in again to access this page.")
      super msg
    end
  end
end
