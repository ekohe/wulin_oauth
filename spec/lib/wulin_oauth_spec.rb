# frozen_string_literal: true

require "rails_helper"
require "tmpdir"

RSpec.describe WulinOAuth do
  describe ".configuration" do
    let(:root) { Pathname(Dir.mktmpdir) }

    before do
      root.join("config").mkpath
      root.join("config", "wulin_oauth.yml").write(<<~YAML)
        provider: &provider
          authorize_uri: https://mima.example.com/oauth/authorize
        #{Rails.env}:
          <<: *provider
          oauth_identifier: client
      YAML
      allow(Rails).to receive(:root).and_return(root)
      described_class.configuration = nil
    end

    after { root.rmtree }

    it "reads this environment's section, anchors merged" do
      expect(described_class.configuration).to eq(
        "authorize_uri" => "https://mima.example.com/oauth/authorize",
        "oauth_identifier" => "client"
      )
    end

    it "builds the authorization URL from it" do
      expect(described_class.new_authorization_url(reset_session: true)).to eq(
        "https://mima.example.com/oauth/authorize?client_id=client&redirect_uri=&reset_session=true"
      )
    end
  end
end
