# frozen_string_literal: true

WulinMaster::AppBarMenu.menus.add_menu(:user_menu,
  icon: :account_circle,
  label: -> { current_user&.email },
  class: "dropdown-trigger",
  data: {target: "user_menu-list"},
  order: 1000) do |sub_menu|
  sub_menu.add_menu(:change_password, label: "Change Password", icon: :lock, order: 1, url: -> { WulinOAuth.change_password_uri }, target: :_blank)
  sub_menu.add_menu(:logout, label: "Logout", icon: :eject, order: 1000, url: -> { "#{WulinOAuth.configuration["logout_uri"]}?redirect_uri=#{logout_url}" })
end
