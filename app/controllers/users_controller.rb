require_dependency WulinPermits::Engine.config.root.join('app', 'controllers', 'users_controller')

class UsersController
  def invite
    invite_result = User.invite(params[:user_ids])
    render json: invite_result
  end

  def destroy
    remove_result = if params[:id] == current_user.id.to_s
      JSON.parse({ success: false, message: 'You can not delete yourself from the APP' }.to_json)
    else
      grid.model.remove(params[:id])
    end

    if remove_result['success']
      render json: { success: true }
    else
      render json: { success: false, error_message: remove_result['message'] }
    end
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
end
