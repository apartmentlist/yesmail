require 'yesmail/version'
require 'yesmail/poster'
require 'yesmail/subscriber'
require 'yesmail/configuration'
require 'yesmail/master'
require 'yesmail/side_table'

module Yesmail

  def self.configuration
    @configuration ||= Configuration.new
  end

  # Yields the global configuration to a block.
  #
  # Example:
  #   Yesmail.configure do |config|
  #     config.username = 'my_username'
  #     config.password = 'my_pass'
  #   end
  def self.configure
    yield configuration if block_given?
  end
end
