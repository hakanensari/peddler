# frozen_string_literal: true

require 'old_helper'
require 'mws'

class Test < MiniTest::Test
  def test_delegation_to_apis
    assert_equal MWS.constants.size, MWS.methods(false).size
    assert_kind_of MWS::Products::Client, MWS.products
  end
end
