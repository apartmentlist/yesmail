require 'httparty'
module Yesmail
  class Poster
    include HTTParty
    debug_output $stderr

    base_uri 'https://services.yesmail.com/enterprise'

    def initialize(u, p)
      @auth = { username: u, password: p }
    end

    def options(post_data, is_post = false)
      hash = { basic_auth: @auth }
      if is_post
        hash[:body] = post_data.to_json
        hash[:headers] = headers
      else
        hash[:query] = post_data
      end
      hash
    end

    def post(post_data, path)
      response = self.class.post(path, options(post_data, true))
      response.response.body
    end

    def headers
      { 'Content-Type' => 'application/json' }
    end

    def update(post_data, path, object_id)
      uri = "#{path}/#{object_id}"
      response = self.class.put(uri, options(post_data, true))
      response.response.body
    end

    def get(get_data, path)
      options = options(get_data)
      response = self.class.get(path, options)
      response.response.body
    end

    def remove(delete_data, path, object_id)
      options = options(delete_data)
      uri = "#{path}/#{object_id}"
      response = self.class.delete(uri, options)
      response.response.body
    end
  end
end