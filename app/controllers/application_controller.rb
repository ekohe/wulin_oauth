class ApplicationController < ActionController::Base
  before_filter :set_request_ip, :except => [:index, :show]

  def set_request_ip
    User.set_current_user(current_user)
    @current_user = User.current_user
    @current_user.ip = request.remote_ip
  end        
end