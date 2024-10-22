# frozen_string_literal: true

require 'test_helper'

class TrendsControllerOverTimeTest < ActionDispatch::IntegrationTest
  test 'should get overTime' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 9, 30)
    get overTime_trends_url, params: {
      start_date: start_date,
      end_date: end_date,
      group_by: 'month'
    }

    assert_response :success

    json_response = response.parsed_body
    assert json_response.is_a?(Array), 'Response should be an array'

    dates = json_response.pluck('date')
    assert_includes dates, '2024-07-01', 'Response should include the start of the grouped period'
    assert_includes dates, '2024-09-01', 'Response should include the end of the grouped period'
  end

  test 'should get overTime from TransactionTrendOverTimeEntity' do
    original_new = TransactionTrendOverTimeEntity.method(:new)
    start_date = '2024-01-01'
    end_date = '2024-03-31'

    TransactionTrendOverTimeEntity
      .expects(:new)
      .with do |actual_start_date, actual_end_date, params|
        params.is_a?(ActionController::Parameters) &&
          actual_start_date == Date.parse(start_date) &&
          actual_end_date == Date.parse(end_date)
      end
      .returns(original_new.call(Date.parse(start_date), Date.parse(end_date)))

    get overTime_trends_url, params: {
      start_date: start_date,
      end_date: end_date,
      group_by: 'month'
    }

    assert_response :success
  end

  test 'should return error when start_date is missing' do
    end_date = Date.new(2024, 9, 30)
    get overTime_trends_url, params: { end_date: end_date }

    assert_response :bad_request
    json_response = response.parsed_body
    assert_includes json_response['errors'], { 'field' => 'startDate', 'message' => 'startDate is required' }
  end

  test 'should return error when end_date is missing' do
    start_date = Date.new(2024, 7, 1)
    get overTime_trends_url, params: { start_date: start_date }

    assert_response :bad_request
    json_response = response.parsed_body
    assert_includes json_response['errors'], { 'field' => 'endDate', 'message' => 'endDate is required' }
  end
end
