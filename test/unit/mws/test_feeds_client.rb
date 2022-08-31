# frozen_string_literal: true

require 'old_helper'
require 'mws/feeds/client'

class TestMWSFeedsClient < MiniTest::Test
  def setup
    @client = MWS::Feeds::Client.new(marketplace: 'GB')
  end

  def test_submitting_feed
    operation = {
      'Action' => 'SubmitFeed',
      'FeedType' => 'type',
      'MarketplaceIdList.Id.1' => '1'
    }

    @client.stub(:run, nil) do
      @client.submit_feed('content', 'type', marketplace_id_list: '1')
    end

    assert_equal operation, @client.operation
  end

  def test_submitting_binary_file_feed
    operation = {
      'Action' => 'SubmitFeed',
      'FeedType' => 'type',
      'MarketplaceIdList.Id.1' => '1'
    }

    @client.stub(:run, nil) do
      random_byte_stream = Random.new.bytes(32)
      @client.submit_feed(random_byte_stream, 'type', marketplace_id_list: '1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_feed_submission_list
    operation = {
      'Action' => 'GetFeedSubmissionList',
      'FeedSubmissionIdList.Id.1' => '1',
      'FeedTypeList.Type.1' => '2',
      'FeedProcessingStatusList.Status.1' => '3'
    }

    @client.stub(:run, nil) do
      @client.get_feed_submission_list(
        feed_submission_id_list: '1',
        feed_type_list: '2',
        feed_processing_status_list: '3'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_feed_submission_list_by_next_token
    operation = {
      'Action' => 'GetFeedSubmissionListByNextToken',
      'NextToken' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_feed_submission_list_by_next_token('1')
    end

    assert_equal operation, @client.operation
  end

  def test_getting_feed_submission_count
    operation = {
      'Action' => 'GetFeedSubmissionCount',
      'FeedTypeList.Type.1' => '1',
      'FeedProcessingStatusList.Status.1' => '2'
    }

    @client.stub(:run, nil) do
      @client.get_feed_submission_count(
        feed_type_list: '1',
        feed_processing_status_list: '2'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_canceling_feed_submissions
    operation = {
      'Action' => 'CancelFeedSubmissions',
      'FeedTypeList.Type.1' => '1',
      'FeedSubmissionIdList.Id.1' => '2'
    }

    @client.stub(:run, nil) do
      @client.cancel_feed_submissions(
        feed_type_list: '1',
        feed_submission_id_list: '2'
      )
    end

    assert_equal operation, @client.operation
  end

  def test_getting_feed_submission_result
    operation = {
      'Action' => 'GetFeedSubmissionResult',
      'FeedSubmissionId' => '1'
    }

    @client.stub(:run, nil) do
      @client.get_feed_submission_result('1')
    end

    assert_equal operation, @client.operation
  end
end
