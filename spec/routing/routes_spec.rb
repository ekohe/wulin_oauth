# frozen_string_literal: true

require "rails_helper"

RSpec.describe "wulin_oauth routes", type: :routing do
  routes { Rails.application.routes }

  it { expect(get: "/login").to route_to("wulin_oauth/user_sessions#new") }
  it { expect(get: "/logout").to route_to("wulin_oauth/user_sessions#destroy") }
  it { expect(get: "/oauth/callback").to route_to("wulin_oauth/user_sessions#callback") }

  # There is no password sign-in: the provider's callback is the only way in.
  it { expect(post: "/login").not_to be_routable }

  it "names the paths the views and redirects use" do
    expect([login_path, logout_path, callback_path]).to eq(%w[/login /logout /oauth/callback])
  end

  # The users resource dispatches to wulin_permits' UsersController, which this suite does not
  # load; recognizing those routes would only fail on that missing constant.
end
