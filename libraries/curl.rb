require 'curb'

module AEM
  module Curl
    def curl(url)
      c = ::Curl::Easy.new(url.to_s)
      c.http_auth_types = :basic
      c.username = u.user
      c.password = u.password
      if block_given?
        yield(c)
      else
        c.perform
      end
      c
    end
  end
end
