class WulinOauth::UserSessionsController < ApplicationController
  layout 'session'

  skip_before_action :require_login, :only => [:new, :create, :callback]

  # GET /login
  def new
    @new_authorization_url = WulinOAuth.new_authorization_url
    respond_to do |format|
      format.html { render }
    end
  end

  def create
    user = WulinOAuth::User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      respond_to do |format|
        root_path ||= "/"
        format.html { redirect_to root_path }
        format.json { render :json => {:status => :success, :user_id => current_user.id} }
      end
    else
      respond_to do |format|
        format.html do
          flash[:notice] = "Username or password incorrect."
          render :new
        end
        format.json { render :json => {:status => :wrong_credentials} }
      end
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end

  # GET /oauth/callback?code=
  def callback
    if params[:error].blank?
      self.current_user = User.get_access_token(params[:code])
      handle_change_password_link
      redirect_to '/'
    else
      @new_authorization_url = WulinOAuth.new_authorization_url(:reset_session => true)
      render 'not_authorized'
      return
    end
  end

  def handle_change_password_link
    if current_user.can_change_password?
      password_link = WulinMaster::AppBarMenu.menus.find(:user_menu).menus.detect {|menu| menu.name == :change_password }
      WulinMaster::AppBarMenu.menus.find(:user_menu).add_menu(:change_password, label: 'Change Password', icon: :lock, order: 1, url: -> { WulinOAuth.change_password_uri }, target: :_blank) if password_link.nil?
    else
      WulinMaster::AppBarMenu.menus.find(:user_menu).menus.select! { |menu| menu.name != :change_password }
    end
  end
end
