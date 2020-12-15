class AddUserScreen < WulinMaster::Screen
  title "Invite User"

  grid InvitedUserGrid, title: 'Invite User', master_model: 'users'
end