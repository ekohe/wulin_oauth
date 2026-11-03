# frozen_string_literal: true

# The login layout (WulinMaster.config.app_title), the callback's change-password menu wiring and
# the user menu all reach for WulinMaster. A host always has it; this stands in for the little of it
# the gem touches, so the suite needs neither wulin_master nor its database.
module WulinMaster
  Config = Struct.new(:app_title)

  def self.config
    @config ||= Config.new("Test App")
  end

  module AppBarMenu
    Entry = Struct.new(:name, :options)

    Menu = Struct.new(:menus) do
      def find(_name)
        self
      end

      def add_menu(name, options = {})
        menus << Entry.new(name, options)
        yield self if block_given?
      end
    end

    def self.menus
      @menus ||= Menu.new([])
    end
  end
end
