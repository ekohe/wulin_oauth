# frozen_string_literal: true

# Stands in for wulin_permits' UsersController: the same constant path, autoloaded by Zeitwerk, with
# the callback and the hook the override builds on.
class UsersController < ActionController::Base
  before_action :require_authorization

  private

  def require_authorization
  end

  def setup_missing_permission
  end
end
