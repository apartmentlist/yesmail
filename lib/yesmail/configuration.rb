module Yesmail
  class Configuration
    def username
      global_config[:yesmail][:username] if global_config
    end

    def password
      global_config[:yesmail][:password] if global_config
    end

    def global_config
      @config ||= begin
        Rails.application.config
      rescue NameError
        #we are not using rails, do nothing
      end
    end
  end
end