class InvitedUserGrid < WulinMaster::Grid
  title 'Users'

  model User

  path '/users?uninvited_users_only=true'

  cell_editable false

  column :email, :width => 500
end
