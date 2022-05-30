# frozen_string_literal: true

require 'devise/jwt/test_helpers'

module Helpers
  module Authorization
    def authorization_header_for(user, headers: {})
      Devise::JWT::TestHelpers.auth_headers(headers, user).fetch('Authorization')
    end
  end
end
