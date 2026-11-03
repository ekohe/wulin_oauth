# frozen_string_literal: true

module WulinOAuth
  module AbstractController
    extend ActiveSupport::Concern

    def current_user
      @current_user ||= begin
        user = User.from_session(session)
        user.ip = format_ip_address(request.remote_ip) if user
        user
      end
    end

    def format_ip_address(ip)
      if ip.starts_with? "::ffff:"
        ip.gsub!(/^::ffff:/, "")
      else
        ip
      end
    end

    def current_user=(new_user)
      session[:user] = new_user&.to_hash
    end
  end

  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :current_user
    end

    def on_login_page?
      params[:controller] == "wulin_oauth/user_sessions" && ["new", "create"].include?(params[:action])
    end

    def require_login
      if current_user.nil?
        unauthorized_response
      else
        logger.warn "Authenticated as #{current_user.email}, ##{current_user.id}, #{current_user.level.inspect}"
      end
    end

    def require_admin
      if current_user.nil? || !current_user.admin?
        unauthorized_response
      else
        logger.warn "Authenticated as #{current_user.email}, ##{current_user.id}, #{current_user.level.inspect}"
      end
    end

    def unauthorized_response
      respond_to do |format|
        format.html do
          flash[:notice] = "You must be logged in to access this page."
          redirect_to login_path
        end
        format.json { render json: {error: :not_authorized} }
      end
      false
    end
  end
end
