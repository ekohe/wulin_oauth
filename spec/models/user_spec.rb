# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  describe ".new" do
    it "reads the provider's attributes and round-trips them through to_hash" do
      user = described_class.new(
        id: 1, email: "test@example.com", access_token: "token", refresh_token: "refresh",
        level: "administrator", app_admin: false, expires_in: 3600
      )

      expect(user.id).to eq(1)
      expect(user.email).to eq("test@example.com")
      expect(user.level).to eq(:administrator)
      expect(user.expire_at.to_i).to be_within(1).of(Time.now.to_i + 3600)
      expect(user.to_hash).to include(id: 1, email: "test@example.com")
    end

    it "accepts string keys" do
      user = described_class.new("id" => 1, "email" => "test@example.com")

      expect([user.id, user.email]).to eq([1, "test@example.com"])
    end
  end

  describe "#admin?" do
    it { expect(described_class.new(level: "administrator")).to be_admin }
    it { expect(described_class.new(app_admin: true)).to be_admin }
    it { expect(described_class.new(level: "member")).not_to be_admin }
  end

  describe "#can_change_password?" do
    it("defaults to true") { expect(described_class.new).to be_can_change_password }
    it("honors an explicit false") { expect(described_class.new(can_change_password: false)).not_to be_can_change_password }
  end

  describe "#expired?" do
    it { expect(described_class.new(id: 1, expire_at: Time.now.to_i - 1)).to be_expired }
    it { expect(described_class.new(id: 1, expire_at: Time.now.to_i + 3600)).not_to be_expired }

    it "is false when the provider issued no expiry" do
      expect(described_class.new(id: 1)).not_to be_expired
    end

    # The cookie store serializes the session with ActiveSupport::JSON: a Time written there comes
    # back as an ISO 8601 string, and "2026-...".to_i is 2026.
    it "survives a JSON session round trip" do
      user = described_class.new(id: 1, expires_in: 3600)

      restored = described_class.from_session(user: ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(user.to_hash)))

      expect(restored).not_to be_expired
      expect(restored.expire_at.to_i).to eq(user.expire_at.to_i)
    end

    # Sessions written before expire_at was stored as seconds hold that ISO string: the user signs in
    # again once, through the provider, rather than the gem parsing a format it no longer writes.
    it "treats an ISO 8601 expire_at from an older session as expired" do
      expect(described_class.new(id: 1, expire_at: (Time.now + 3600).iso8601)).to be_expired
    end
  end

  describe ".from_session" do
    it "is nil without a stored user" do
      expect(described_class.from_session({})).to be_nil
    end

    it "rebuilds the user from the stored attributes" do
      user = described_class.from_session(user: {id: 1, email: "test@example.com"})

      expect([user.id, user.email]).to eq([1, "test@example.com"])
    end
  end

  describe ".get_access_token" do
    it "is nil without a code" do
      expect(described_class.get_access_token(nil)).to be_nil
    end
  end

  describe "the ActiveRecord-shaped surface WulinMaster grids read" do
    it "answers like a users table" do
      expect(described_class.primary_key).to eq("id")
      expect(described_class.table_name).to eq("users")
      expect(described_class.column_names).to eq(%w[email])
      expect(described_class.columns.map(&:name)).to eq([:email])
      expect(described_class.human_attribute_name(:email)).to eq("Email")
      expect(described_class.finder_needs_type_condition?).to be(false)
      expect(described_class.reflections).to eq({})
    end

    it "treats query methods as no-ops" do
      expect(described_class.order(:email).where(id: 1).limit(10)).to be(described_class)
    end

    it "lists nobody without a current user" do
      expect(described_class.all).to eq([])
    end

    it "finds from the cached list of all users" do
      expect(described_class.find(1)).to be_nil
      expect(described_class.find([1, 2])).to eq([])
    end
  end
end
