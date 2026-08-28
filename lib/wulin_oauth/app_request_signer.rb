# frozen_string_literal: true

require "openssl"

module WulinOAuth
  module AppRequestSigner
    TIMESTAMP_PARAM = :app_timestamp
    SIGNATURE_PARAM = :app_signature

    def self.params(oauth_token:, secret: WulinOAuth.oauth_secret, timestamp: Time.now.to_i)
      timestamp = timestamp.to_s
      {
        oauth_token: oauth_token,
        TIMESTAMP_PARAM => timestamp,
        SIGNATURE_PARAM => signature(secret: secret, timestamp: timestamp, oauth_token: oauth_token)
      }
    end

    def self.signature(secret:, timestamp:, oauth_token:)
      OpenSSL::HMAC.hexdigest("SHA256", secret.to_s, "#{timestamp}:#{oauth_token}")
    end
  end
end
