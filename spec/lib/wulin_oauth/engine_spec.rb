# frozen_string_literal: true

require "rails_helper"

RSpec.describe WulinOAuth::Engine do
  # Autoloaded, the overrides would take the constant paths users_controller and user_grid -- or
  # lose them to wulin_permits' files, depending on which engine Zeitwerk saw first.
  it "keeps app/overrides away from Zeitwerk" do
    overrides = described_class.root.join("app", "overrides").to_s

    expect(Rails.autoloaders.main.all_expected_cpaths.keys.grep(/\A#{Regexp.escape(overrides)}/)).to be_empty
  end

  # Loading UsersController at boot would run WulinMaster::ScreenController.inherited, which calls the
  # host's ApplicationController.define_menu -- absent while a generator or a template runs.
  it "loads neither class it extends while booting" do
    expect(LOADED_AT_BOOT).to be_empty
  end

  it "extends UsersController once Zeitwerk loads it" do
    expect(UsersController.public_method_defined?(:invite)).to be(true)
    expect(UsersController.public_method_defined?(:send_mail)).to be(true)
    expect(UsersController.private_method_defined?(:user_management_read_permission)).to be(true)
  end

  it "extends UserGrid once Zeitwerk loads it" do
    expect(UserGrid.columns).to include(:a_password, :welcome_email_sent_at)
    expect(UserGrid.actions).to include(:add_user, :remove_user, :reset_account)
  end

  it "gives ActionController::Base controllers current_user and the login filters" do
    expect(ActionController::Base.method_defined?(:current_user)).to be(true)
    expect(ActionController::Base.method_defined?(:require_login)).to be(true)
  end

  # Not AbstractController::Base, which also sits under ActionController::API and every mailer.
  it "leaves ActionController::API alone" do
    expect(ActionController::API.method_defined?(:current_user)).to be(false)
    expect(ActionController::API.method_defined?(:require_login)).to be(false)
  end

  it "adds the user menu to WulinMaster's app bar" do
    expect(WulinMaster::AppBarMenu.menus.menus.map(&:name)).to include(:user_menu, :change_password, :logout)
  end
end
