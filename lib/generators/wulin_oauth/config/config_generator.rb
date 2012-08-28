module WulinOauth
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    def copy_config_file
      copy_file 'wulin_oauth.yml', "config/wulin_oauth.yml"
    end
  end
end
