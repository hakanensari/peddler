# frozen_string_literal: true

require 'old_helper'
require 'mws/reports/client'

class TestMWSReportsClient < MiniTest::Test
  def setup
    @client = MWS::Reports::Client.new
  end

  def test_requesting_report
    operation = {
      'Action' => 'RequestReport',
      'ReportType' => 'foo',
      'MarketplaceIdList.Id.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.request_report('foo', marketplace_id_list: ['1'])
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_request_list
    operation = {
      'Action' => 'GetReportRequestList',
      'ReportRequestIdList.Id.1' => '1',
      'ReportTypeList.Type.1' => '2',
      'ReportProcessingStatusList.Status.1' => '3'
    }

    @client.stub(:run, nil) do
      @client.get_report_request_list(
        report_request_id_list: '1',
        report_type_list: '2',
        report_processing_status_list: '3'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_request_list_by_next_token
    operation = {
      'Action' => 'GetReportRequestListByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_report_request_list_by_next_token('1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_request_count
    operation = {
      'Action' => 'GetReportRequestCount',
      'ReportTypeList.Type.1' => '1',
      'ReportProcessingStatusList.Status.1' => '2'
    }

    @client.stub(:run, nil) do
      @client.get_report_request_count(
        report_type_list: '1',
        report_processing_status_list: '2'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_canceling_report_requests
    operation = {
      'Action' => 'CancelReportRequests',
      'ReportTypeList.Type.1' => '1',
      'ReportProcessingStatusList.Status.1' => '2'
    }

    @client.stub(:run, nil) do
      @client.cancel_report_requests(
        report_type_list: '1',
        report_processing_status_list: '2'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_list
    operation = {
      'Action' => 'GetReportList',
      'ReportTypeList.Type.1' => '1',
      'ReportRequestIdList.Id.1' => '2'
    }

    @client.stub(:run, nil) do
      @client.get_report_list(
        report_type_list: '1',
        report_request_id_list: '2'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_list_by_next_token
    operation = {
      'Action' => 'GetReportListByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_report_list_by_next_token('1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_count
    operation = {
      'Action' => 'GetReportCount',
      'ReportTypeList.Type.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_report_count(
        report_type_list: '1'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report
    operation = {
      'Action' => 'GetReport',
      'ReportId' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_report('1')
    end

    assert_equal operation, @client.operation
  end

  def test_managing_report_schedule
    operation = {
      'Action' => 'ManageReportSchedule',
      'ReportType' => '1',
      'Schedule' => '2'
    }

    @client.stub(:run, nil) do
      @client.manage_report_schedule('1', '2')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_schedule_list
    operation = {
      'Action' => 'GetReportScheduleList',
      'ReportTypeList.Type.1' => '1',
      'ReportTypeList.Type.2' => '2'
    }

    @client.stub(:run, nil) do
      @client.get_report_schedule_list('1', '2')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_report_schedule_list_by_next_token
    assert_raises NotImplementedError do
      @client.get_report_schedule_list_by_next_token
    end
  end

  def test_getting_report_schedule_count
    operation = {
      'Action' => 'GetReportScheduleCount',
      'ReportTypeList.Type.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_report_schedule_count('1')
    end

    assert_equal operation, @client.operation
  end

  def test_updating_report_acknowledgements
    operation = {
      'Action' => 'UpdateReportAcknowledgements',
      'Acknowledged' => true,
      'ReportIdList.Id.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.update_report_acknowledgements(true, '1')
    end

    assert_equal operation, @client.operation
  end
end
