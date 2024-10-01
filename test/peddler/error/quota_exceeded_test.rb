# frozen_string_literal: true

require "helper"

require "peddler/api/product_pricing_v0"

module Peddler
  class Error
    class QuotaExceededTest < Minitest::Test
      include FeatureHelpers

      # I depleted quota before recording this test.
      def test_quota_exceeded
        error = assert_raises(QuotaExceeded) do
          api.get_pricing("A1F83G8C2ARO7P", "Asin", asins: ["188864544X"])
        end
        assert_equal(429, error.cause.status)
      end

      private

      def api_class
        API::ProductPricingV0
      end
    end
  end
end
