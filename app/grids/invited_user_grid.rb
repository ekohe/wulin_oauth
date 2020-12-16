class InvitedUserGrid < WulinMaster::Grid
  title 'Users'

  model User

  path '/users?uninvited_users_only=true'

  cell_editable false

  action :create_new_user, icon: :person_add, global: true

  column :email, :width => 500
end
