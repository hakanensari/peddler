# frozen_string_literal: true

require 'old_helper'
require 'mws/finances/client'

class TestMWSFinancesClient < MiniTest::Test
  def setup
    @client = MWS::Finances::Client.new
  end

  def test_listing_financial_event_groups
    operation = {
      'Action' => 'ListFinancialEventGroups',
      'FinancialEventGroupStartedAfter' => '2015-01-01'
    }

    @client.stub(:run, nil) do
      @client.list_financial_event_groups('2015-01-01')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_financial_event_groups_by_next_token
    operation = {
      'Action' => 'ListFinancialEventGroupsByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_financial_event_groups_by_next_token('1')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_financial_events
    operation = {
      'Action' => 'ListFinancialEvents',
      'AmazonOrderId' => '123'
    }

    @client.stub(:run, nil) do
      @client.list_financial_events(amazon_order_id: '123')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_financial_events_by_next_token
    operation = {
      'Action' => 'ListFinancialEventsByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.list_financial_events_by_next_token('1')
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
