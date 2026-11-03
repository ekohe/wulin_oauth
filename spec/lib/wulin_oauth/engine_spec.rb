# frozen_string_literal: true

require "rails_helper"

RSpec.describe WulinOAuth::Engine do
  it "gives ActionController::Base controllers current_user and the login filters" do
    expect(ActionController::Base.method_defined?(:current_user)).to be(true)
    expect(ActionController::Base.method_defined?(:require_login)).to be(true)
  end

  it "adds the user menu to WulinMaster's app bar" do
    expect(WulinMaster::AppBarMenu.menus.menus.map(&:name)).to include(:user_menu, :change_password, :logout)
  end
end
