# This holds the information that Yesmail needs before it allows any api calls.
# These values will be placed in json when sending Yesmail queries
#
# The Yesmail module initializes its configuration on startup. You can change
# it at the command line:
# Yesmail::configuratoin.username = 'blah'
# Yesmail::configuratoin.division = 'Retention'

module Yesmail
  class Configuration
    attr_accessor :username, :password, :subscription_state, :division
  end
end
