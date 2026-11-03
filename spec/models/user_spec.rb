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
