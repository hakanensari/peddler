# frozen_string_literal: true

require 'old_helper'
require 'mws/sellers/client'

class TestMWSSellersClient < MiniTest::Test
  def setup
    @client = MWS::Sellers::Client.new
  end

  def test_listing_marketplace_participations
    operation = {
      'Action' => 'ListMarketplaceParticipations'
    }

    @client.stub(:run, nil) do
      @client.list_marketplace_participations
    end

    assert_equal operation, @client.operation
  end

  def test_listing_marketplace_participations_by_next_token
    operation = {
      'Action' => 'ListMarketplaceParticipationsByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_marketplace_participations_by_next_token('1')
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
