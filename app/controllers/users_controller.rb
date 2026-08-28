require_dependency WulinPermits::Engine.config.root.join('app', 'controllers', 'users_controller')

class UsersController
  skip_before_action :require_authorization, only: [:invite, :create, :destroy, :send_mail]

  def invite
    invite_result = User.invite(params[:user_ids])
    render json: invite_result
  end

  def destroy
    remove_result = if params[:id] == current_user.id.to_s
      JSON.parse({ success: false, error_message: 'You can not delete yourself from the APP' }.to_json)
    else
      grid.model.remove(params[:id])
    end

    render json: remove_result
  rescue StandardError
    render json: { success: false, error_message: $ERROR_INFO.message }
  end

  def create
    create_result = User.create(user_params)
    if create_result['success']
      user_id = create_result['id']
      User.invite(user_id)
    end

    render json: create_result
  end

  def send_mail
    send_mail_result = User.send_mail(params[:user_id])

    render json: send_mail_result
  end

  private

    def user_params
      params.require(:user).permit(:email)
    end

    def setup_missing_permission
      case action_name
      when "create", "invite"
        create_permission(WulinPermits::UserManagement::INVITE)
      when "send_mail"
        create_permission(WulinPermits::UserManagement::RESET)
      when "destroy"
        create_permission(WulinPermits::UserManagement::DELETE)
      when "index", "show"
        user_management_read_permission || super
      else
        super
      end
    end

    # Returns nil for screens outside user management so the caller falls back to
    # the default screen-derived permission.
    def user_management_read_permission
      screen_param = params[:screen].to_s
      if screen_param == "AddUserScreen" || params[:uninvited_users_only] == "true"
        create_permission(WulinPermits::UserManagement::INVITE)
      elsif screen_param == "AddUserForRoleScreen"
        create_permission(WulinPermits::UserManagement::REVERSE_SCREEN_CUD)
      elsif %w[UserScreen MasterUserDetailRoleScreen].include?(screen_param) || screen_param.blank?
        create_permission(WulinPermits::UserManagement::SCREEN_READ)
      end
    end
end
