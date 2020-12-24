# frozen_string_literal: true

require_dependency WulinPermits::Engine.config.root.join('app', 'grids', 'user_grid')

# Add account creation capabilities
class UserGrid
  column :a_password, label: 'Has a password?', editable: false, formable: false, sortable: false, filterable: false
  column :welcome_email_sent_at, editable: false, formable: false
  action :add_user, screen: 'AddUserScreen', model: 'user', icon: :add_box, global: true, title: 'Invite User', only: [:MasterUserDetailRoleScreen]
  action :remove_user, screen: 'AddUserScreen', model: 'user', icon: :clear, global: true, title: 'Remove User', only: [:MasterUserDetailRoleScreen]
end
