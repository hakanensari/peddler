# frozen_string_literal: true

require "helper"

require "peddler/api/sellers_v1"

module Peddler
  class API
    class SellersV1Test < Minitest::Test
      include FeatureHelpers

      def test_get_marketplace_participations
        res = api.get_marketplace_participations

        assert_predicate(res.status, :ok?)
      end
    end
  end
end
