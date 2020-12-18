# frozen_string_literal: true

require_dependency WulinPermits::Engine.config.root.join('app', 'grids', 'user_grid')

# Add account creation capabilities
class UserGrid
  action :add_user, screen: 'AddUserScreen', model: 'user', icon: :add_box, global: true, title: 'Invite User', only: [:MasterUserDetailRoleScreen]
end
