class InvitedUserGrid < WulinMaster::Grid
  title 'Users'

  model User

  path '/users?uninvited_users_only=true'

  cell_editable false

  # Creating a user posts to /users and then sends the welcome email, without which
  # the new account has no password and cannot log in.
  action :create_new_user, icon: :person_add, global: true, title: 'Create New User',
    authorized?: ->(user) {
      user.has_permission_with_name?(WulinPermits::UserManagement::INVITE) &&
        user.has_permission_with_name?(WulinPermits::UserManagement::RESET)
    }

  column :email, :width => 500
end
