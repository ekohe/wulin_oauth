class AddUserScreen < WulinMaster::Screen
  title "Invite User"

  grid InvitedUserGrid, title: 'Invite User', master_model: 'users'

  def authorized?(user = nil)
    user ||= current_user
    return false if user.blank?

    user.has_permission_with_name?(WulinPermits::UserManagement::INVITE)
  end

  alias_method :authorize_create?, :authorized?
end
