# frozen_string_literal: true

# Stands in for wulin_permits' UserGrid: the same constant path, autoloaded by Zeitwerk, recording the
# columns and actions the override declares.
class UserGrid
  class << self
    def columns
      @columns ||= []
    end

    def actions
      @actions ||= []
    end

    def column(name, **)
      columns << name
    end

    def action(name, **)
      actions << name
    end
  end
end
