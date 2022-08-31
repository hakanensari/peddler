# frozen_string_literal: true

require 'old_helper'
require 'mws/subscriptions/client'

class TestMWSSubscriptionsClient < MiniTest::Test
  def setup
    @client = MWS::Subscriptions::Client.new
  end

  def test_registering_destination
    operation = {
      'Action' => 'RegisterDestination',
      'MarketplaceId' => '321',
      'Destination.DeliveryChannel' => 'SQS',
      'Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Destination.AttributeList.member.1.Value' => 'foo'
    }

    @client.stub(:run, nil) do
      @client.register_destination('foo', '321')
    end

    assert_equal operation, @client.operation
  end

  def test_deregistering_destination
    operation = {
      'Action' => 'DeregisterDestination',
      'MarketplaceId' => '123',
      'Destination.DeliveryChannel' => 'SQS',
      'Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Destination.AttributeList.member.1.Value' => 'foo'
    }

    @client.stub(:run, nil) do
      @client.deregister_destination('foo', '123')
    end

    assert_equal operation, @client.operation
  end

  def test_deregistering_destination_with_alternate_marketplace
    operation = {
      'Action' => 'DeregisterDestination',
      'MarketplaceId' => '321',
      'Destination.DeliveryChannel' => 'SQS',
      'Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Destination.AttributeList.member.1.Value' => 'foo'
    }

    @client.stub(:run, nil) do
      @client.deregister_destination('foo', '321')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_registered_destinations
    operation = {
      'Action' => 'ListRegisteredDestinations',
      'MarketplaceId' => '321'
    }

    @client.stub(:run, nil) do
      @client.list_registered_destinations('321')
    end

    assert_equal operation, @client.operation
  end

  def test_sending_test_notification_to_destination
    operation = {
      'Action' => 'SendTestNotificationToDestination',
      'MarketplaceId' => '321',
      'Destination.DeliveryChannel' => 'SQS',
      'Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Destination.AttributeList.member.1.Value' => 'foo'
    }

    @client.stub(:run, nil) do
      @client.send_test_notification_to_destination('foo', '321')
    end

    assert_equal operation, @client.operation
  end

  def test_creating_subscription
    operation = {
      'Action' => 'CreateSubscription',
      'MarketplaceId' => '321',
      'Subscription.IsEnabled' => true,
      'Subscription.NotificationType' => 'foo',
      'Subscription.Destination.DeliveryChannel' => 'SQS',
      'Subscription.Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Subscription.Destination.AttributeList.member.1.Value' => 'bar'
    }

    @client.stub(:run, nil) do
      @client.create_subscription('foo', 'bar', '321')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_subscription
    operation = {
      'Action' => 'GetSubscription',
      'MarketplaceId' => '321',
      'NotificationType' => 'foo',
      'Destination.DeliveryChannel' => 'SQS',
      'Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Destination.AttributeList.member.1.Value' => 'bar'
    }

    @client.stub(:run, nil) do
      @client.get_subscription('foo', 'bar', '321')
    end

    assert_equal operation, @client.operation
  end

  def test_deleting_subscription
    operation = {
      'Action' => 'DeleteSubscription',
      'MarketplaceId' => '321',
      'NotificationType' => 'foo',
      'Destination.DeliveryChannel' => 'SQS',
      'Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Destination.AttributeList.member.1.Value' => 'bar'
    }

    @client.stub(:run, nil) do
      @client.delete_subscription('foo', 'bar', '321')
    end

    assert_equal operation, @client.operation
  end

  def test_listing_subscriptions
    operation = {
      'Action' => 'ListSubscriptions',
      'MarketplaceId' => '321'
    }

    @client.stub(:run, nil) do
      @client.list_subscriptions('321')
    end

    assert_equal operation, @client.operation
  end

  def test_updating_subscription
    operation = {
      'Action' => 'UpdateSubscription',
      'MarketplaceId' => '321',
      'Subscription.IsEnabled' => true,
      'Subscription.NotificationType' => 'foo',
      'Subscription.Destination.DeliveryChannel' => 'SQS',
      'Subscription.Destination.AttributeList.member.1.Key' => 'sqsQueueUrl',
      'Subscription.Destination.AttributeList.member.1.Value' => 'bar'
    }

    @client.stub(:run, nil) do
      @client.update_subscription('foo', 'bar', true, '321')
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
