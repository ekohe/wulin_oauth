module WulinOAuth
  module Controller
    ## this one manages the usual self.included, klass_eval stuff
    extend ActiveSupport::Concern
    
    included do
      class_eval do
        helper_method :current_user
      end
    end
      
    module InstanceMethods
      def current_user
        @current_user ||= User.from_session(session)
      end
      
      def current_user=(new_user)
        if new_user.nil?
          session[:user] = nil
        else
          session[:user] = new_user.to_hash
        end
      end

      def on_login_page?
        params[:controller] == "wulin_oauth/user_sessions" && ["new", "create"].include?(params[:action])
      end

      def require_login
        if current_user.nil?
          return unauthorized_response
        else
          logger.warn "Authenticated as #{current_user.email}, ##{current_user.id}"
        end
      end

      def unauthorized_response
        respond_to do |format|
          format.html do
            flash[:notice] = "You must be logged in to access this page."
            redirect_to login_path
          end
          format.json { render :json => {:error => :not_authorized} }
        end
        false
      end
    end
  end
end

::ActionController::Base.send :include, WulinOAuth::Controller
