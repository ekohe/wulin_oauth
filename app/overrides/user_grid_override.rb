# frozen_string_literal: true

# Adds account creation to wulin_permits' UserGrid. Applied by WulinOAuth::Engine each time Zeitwerk
# loads UserGrid, and not itself autoloaded: as app/grids/user_grid.rb it would shadow wulin_permits'.
UserGrid.class_eval do
  column :a_password, label: "Has a password?", editable: false, formable: false, sortable: false, filterable: false
  column :welcome_email_sent_at, editable: false, formable: false
  action :add_user, screen: "AddUserScreen", model: "user", icon: :add_box, global: true, title: "Invite User", only: [:MasterUserDetailRoleScreen],
    authorized?: ->(user) { user.has_permission_with_name?(WulinPermits::UserManagement::INVITE) }
  action :remove_user, icon: :clear, title: "Remove User", only: [:MasterUserDetailRoleScreen],
    authorized?: ->(user) { user.has_permission_with_name?(WulinPermits::UserManagement::DELETE) }
  action :reset_account, icon: :contact_mail, title: "Reset Account", only: [:MasterUserDetailRoleScreen],
    authorized?: ->(user) { user.has_permission_with_name?(WulinPermits::UserManagement::RESET) }
end
