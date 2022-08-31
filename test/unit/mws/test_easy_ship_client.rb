# frozen_string_literal: true

require 'old_helper'
require 'mws/easy_ship/client'

# I'm just replicating the example payloads in the Amazon docs.
class TestMWSEasyShipClient < MiniTest::Test
  def setup
    @client = MWS::EasyShip::Client.new

    # Some reused parameters
    @dimensions = PackageDimensions.new(12, 12, 12, 'cm')
    @weight = PackageWeight.new(23, 'g')
    @pickup_slot = PackagePickupSlot.new('Xyt123bbdg=',
                                         Time.new(2018, 2, 21, 7, 30, 0, 0),
                                         Time.new(2018, 2, 21, 10, 30, 0, 0))
    @scheduled_id = ScheduledPackageId.new('903-1713775-3598252',
                                           '1ab0f06a-9149-87e0-aba9-7098117872d6')
  end

  def test_listing_pickup_slots
    operation = { 'Action' => 'ListPickupSlots',
                  'MarketplaceId' => 'A21TJRUUN4KGV',
                  'AmazonOrderId' => '903-1713775-3598252',
                  'PackageDimensions.Length' => 12,
                  'PackageDimensions.Width' => 12,
                  'PackageDimensions.Height' => 12,
                  'PackageDimensions.Unit' => 'cm',
                  'PackageWeight.Value' => 23,
                  'PackageWeight.Unit' => 'g' }
    @client.stub(:run, nil) do
      @client.list_pickup_slots('A21TJRUUN4KGV', '903-1713775-3598252',
                                @dimensions, @weight)
    end

    assert_equal operation, @client.operation
  end

  def test_creating_scheduled_package
    operation = { 'Action' => 'CreateScheduledPackage',
                  'MarketplaceId' => 'A21TJRUUN4KGV',
                  'AmazonOrderId' => '903-1713775-3598252',
                  'PackageRequestDetails.PackageDimensions.Length' => 12,
                  'PackageRequestDetails.PackageDimensions.Width' => 12,
                  'PackageRequestDetails.PackageDimensions.Height' => 12,
                  'PackageRequestDetails.PackageDimensions.Unit' => 'cm',
                  'PackageRequestDetails.PackageWeight.Value' => 23,
                  'PackageRequestDetails.PackageWeight.Unit' => 'g',
                  'PackageRequestDetails.PackagePickupSlot.SlotId' =>
                    'Xyt123bbdg=',
                  'PackageRequestDetails.PackagePickupSlot.PickupTimeStart' =>
                    '2018-02-21T07:30:00.00Z',
                  'PackageRequestDetails.PackagePickupSlot.PickupTimeEnd' =>
                    '2018-02-21T10:30:00.00Z',
                  'PackageRequestDetails.PackageIdentifier' => 'Package1' }

    @client.stub(:run, nil) do
      request_details = PackageRequestDetails.new(@dimensions, @weight,
                                                  @pickup_slot, 'Package1')
      @client.create_scheduled_package('A21TJRUUN4KGV', '903-1713775-3598252',
                                       request_details)
    end

    assert_equal operation, @client.operation
  end

  def test_updating_scheduled_packages
    operation = { 'Action' => 'UpdateScheduledPackages',
                  'MarketplaceId' => 'A21TJRUUN4KGV',
                  'ScheduledPackageUpdateDetailsList.PackageUpdateDetails.1.ScheduledPackageId.AmazonOrderId' => '903-1713775-3598252',
                  'ScheduledPackageUpdateDetailsList.PackageUpdateDetails.1.ScheduledPackageId.PackageId' => '1ab0f06a-9149-87e0-aba9-7098117872d6',
                  'ScheduledPackageUpdateDetailsList.PackageUpdateDetails.1.PackagePickupSlot.SlotId' => 'Xyt123bbdg=',
                  'ScheduledPackageUpdateDetailsList.PackageUpdateDetails.1.PackagePickupSlot.PickupTimeStart' => '2018-02-21T07:30:00.00Z',
                  'ScheduledPackageUpdateDetailsList.PackageUpdateDetails.1.PackagePickupSlot.PickupTimeEnd' => '2018-02-21T10:30:00.00Z' }

    update_details = PackageUpdateDetails.new(@scheduled_id, @pickup_slot)
    @client.stub(:run, nil) do
      @client.update_scheduled_packages('A21TJRUUN4KGV', [update_details])
    end

    assert_equal operation, @client.operation
  end

  def test_getting_scheduled_package
    operation = { 'Action' => 'GetScheduledPackage',
                  'MarketplaceId' => 'A21TJRUUN4KGV',
                  'ScheduledPackageId.AmazonOrderId' => '903-1713775-3598252',
                  'ScheduledPackageId.PackageId' => '1ab0f06a-9149-87e0-aba9-7098117872d6' }
    @client.stub(:run, nil) do
      @client.get_scheduled_package('A21TJRUUN4KGV', @scheduled_id)
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

  PackageDimensions = Struct.new(:length, :width, :height, :unit)
  PackageWeight = Struct.new(:value, :unit)
  PackageRequestDetails = Struct.new(:package_dimensions, :package_weight,
                                     :package_pickup_slot, :package_identifier)
  PackagePickupSlot = Struct.new(:slot_id, :pickup_time_start, :pickup_time_end)
  ScheduledPackageId = Struct.new(:amazon_order_id, :package_id)
  PackageUpdateDetails = Struct.new(:scheduled_package_id, :package_pickup_slot)
end
