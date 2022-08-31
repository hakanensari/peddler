# frozen_string_literal: true

require 'helper'
require 'selling_partner/client'

module SellingPartner
  class TestClient < MiniTest::Test
    include Client

    def test_user_agent
      default_headers = client.default_options.headers
      assert default_headers['User-Agent']
    end
  end
end
