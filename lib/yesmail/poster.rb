require 'httparty'
module Yesmail
  class Poster
    include HTTParty
    debug_output $stderr

    base_uri 'https://services.yesmail.com/enterprise'

    def initialize(u, p)
      @auth = { username: u, password: p }
    end

    def post(post_data, path)
      options = { basic_auth: @auth, :body => post_data}
      self.class.post(path, options)
    end
  end
end