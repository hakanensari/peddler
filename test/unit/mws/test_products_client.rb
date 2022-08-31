# frozen_string_literal: true

require 'old_helper'
require 'mws/products/client'

class TestMWSProductsClient < MiniTest::Test
  def setup
    @client = MWS::Products::Client.new
  end

  def test_listing_matching_products
    operation = {
      'Action' => 'ListMatchingProducts',
      'MarketplaceId' => '123',
      'Query' => 'foo'
    }

    @client.stub(:run, nil) do
      @client.list_matching_products('123', 'foo')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_matching_product_for_id
    operation = {
      'Action' => 'GetMatchingProductForId',
      'MarketplaceId' => '123',
      'IdType' => 'foo',
      'IdList.Id.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_matching_product_for_id('123', 'foo', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_matching_product
    operation = {
      'Action' => 'GetMatchingProduct',
      'MarketplaceId' => '123',
      'ASINList.ASIN.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_matching_product('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_competitive_pricing_for_sku
    operation = {
      'Action' => 'GetCompetitivePricingForSKU',
      'MarketplaceId' => '123',
      'SellerSKUList.SellerSKU.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_competitive_pricing_for_sku('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_competitive_pricing_for_asin
    operation = {
      'Action' => 'GetCompetitivePricingForASIN',
      'MarketplaceId' => '123',
      'ASINList.ASIN.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_competitive_pricing_for_asin('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_lowest_offer_listings_for_sku
    operation = {
      'Action' => 'GetLowestOfferListingsForSKU',
      'MarketplaceId' => '123',
      'SellerSKUList.SellerSKU.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_lowest_offer_listings_for_sku('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_lowest_priced_offers_for_sku
    operation = {
      'Action' => 'GetLowestPricedOffersForSKU',
      'MarketplaceId' => '123',
      'SellerSKU' => '1',
      'ItemCondition' => 'New'
    }

    @client.stub(:run, nil) do
      @client.get_lowest_priced_offers_for_sku('123', '1', 'New')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_lowest_priced_offers_for_asin
    operation = {
      'Action' => 'GetLowestPricedOffersForASIN',
      'MarketplaceId' => '123',
      'ASIN' => '1',
      'ItemCondition' => 'New'
    }

    @client.stub(:run, nil) do
      @client.get_lowest_priced_offers_for_asin('123', '1', 'New')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_lowest_offer_listings_for_asin
    operation = {
      'Action' => 'GetLowestOfferListingsForASIN',
      'MarketplaceId' => '123',
      'ASINList.ASIN.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_lowest_offer_listings_for_asin('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_my_fees_estimate
    operation = {
      'Action' => 'GetMyFeesEstimate',
      'FeesEstimateRequestList.FeesEstimateRequest.1.MarketplaceId' => '123',
      'FeesEstimateRequestList.FeesEstimateRequest.1.IdType' => 'ASIN',
      'FeesEstimateRequestList.FeesEstimateRequest.1.IdValue' => '1234567890',
      'FeesEstimateRequestList.FeesEstimateRequest.1.Identifier' => 'foo',
      'FeesEstimateRequestList.FeesEstimateRequest.1.IsAmazonFulfilled' => true,
      'FeesEstimateRequestList.FeesEstimateRequest.1.PriceToEstimateFees.ListingPrice.CurrencyCode' => 'USD',
      'FeesEstimateRequestList.FeesEstimateRequest.1.PriceToEstimateFees.ListingPrice.Amount' => 30.00,
      'FeesEstimateRequestList.FeesEstimateRequest.1.PriceToEstimateFees.Shipping.CurrencyCode' => 'USD',
      'FeesEstimateRequestList.FeesEstimateRequest.1.PriceToEstimateFees.Shipping.Amount' => 3.99,
      'FeesEstimateRequestList.FeesEstimateRequest.1.PriceToEstimateFees.Points.PointsNumber' => 0
    }

    @client.stub(:run, nil) do
      @client.get_my_fees_estimate(
        marketplace_id: '123',
        id_type: 'ASIN',
        id_value: '1234567890',
        identifier: 'foo',
        is_amazon_fulfilled: true,
        price_to_estimate_fees: {
          listing_price: {
            currency_code: 'USD',
            amount: 30.00
          },
          shipping: {
            currency_code: 'USD',
            amount: 3.99
          },
          points: {
            points_number: 0
          }
        }
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_my_price_for_sku
    operation = {
      'Action' => 'GetMyPriceForSKU',
      'MarketplaceId' => '123',
      'SellerSKUList.SellerSKU.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_my_price_for_sku('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_my_price_for_asin
    operation = {
      'Action' => 'GetMyPriceForASIN',
      'MarketplaceId' => '123',
      'ASINList.ASIN.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_my_price_for_asin('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_product_categories_for_sku
    operation = {
      'Action' => 'GetProductCategoriesForSKU',
      'MarketplaceId' => '123',
      'SellerSKU' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_product_categories_for_sku('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_product_categories_for_asin
    operation = {
      'Action' => 'GetProductCategoriesForASIN',
      'MarketplaceId' => '123',
      'ASIN' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_product_categories_for_asin('123', '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_service_status
    operation = {
      'Action' => 'GetServiceStatus'
    }

    @client.stub(:run, nil) do
      @client.get_service_status
    end

    assert_equal operation, @client.operation
  end
end
