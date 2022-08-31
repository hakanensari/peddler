# frozen_string_literal: true

require 'helper'
require 'selling_partner/access_token'

module SellingPartner
  class TestAccessToken < IntegrationTest
    def test_request_with_refresh_token
      skip
    end

    def test_request_for_grantless_operations
      assert access_token.request_for_grantless_operations('sellingpartnerapi::notifications')
    end

    private

    def access_token
      AccessToken.new('client_id', 'client_secret')
    end
  end
end
