# frozen_string_literal: true

require "rails_helper"

RSpec.describe WulinOauth::UserSessionsController, type: :controller do
  routes { Rails.application.routes }
  render_views

  describe "GET new" do
    it "renders the login page" do
      get :new

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET destroy" do
    it "resets the session and redirects to the login page" do
      session[:user] = {id: 1}

      get :destroy

      expect(response).to redirect_to(login_path)
      expect(session[:user]).to be_nil
    end
  end

  describe "GET callback" do
    it "renders not_authorized when the provider returns an error" do
      get :callback, params: {error: "access_denied"}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Not authorized")
    end

    it "resets the session and redirects to login when the token exchange fails" do
      allow(User).to receive(:get_access_token).and_return(nil)
      session[:user] = {id: 1}

      get :callback, params: {code: "bad-code"}

      expect(response).to redirect_to(login_path)
      expect(session[:user]).to be_nil
    end

    it "signs the user in on success" do
      allow(User).to receive(:get_access_token).and_return(User.new(id: 1, email: "test@example.com"))

      get :callback, params: {code: "good-code"}

      expect(response).to redirect_to("/")
      expect(session[:user][:id]).to eq(1)
    end
  end

  describe "#current_user" do
    before { get :new }

    it "drops an expired token from the session" do
      session[:user] = {id: 1, email: "test@example.com", expire_at: Time.now.to_i - 60}

      expect(controller.current_user).to be_nil
      expect(session[:user]).to be_nil
    end

    it "keeps an unexpired token" do
      session[:user] = {id: 1, email: "test@example.com", expire_at: Time.now.to_i + 3600}

      expect(controller.current_user.id).to eq(1)
      expect(session[:user]).not_to be_nil
    end
  end
end
