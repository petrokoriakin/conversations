class ServerConfig
  class << self
    def config
      @@config ||= YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config/servers.yml"))
    end

    def social_api
      config["social_api"][RAILS_ENV]
    end
  end
end
