# frozen_string_literal: true

require "rails_helper"

RSpec.describe WulinOAuth::AppRequestSigner do
  it "signs the timestamp and token with the client secret" do
    params = described_class.params(oauth_token: "token", secret: "secret", timestamp: 1_700_000_000)

    expect(params).to eq(
      oauth_token: "token",
      app_timestamp: "1700000000",
      app_signature: OpenSSL::HMAC.hexdigest("SHA256", "secret", "1700000000:token")
    )
  end
end
