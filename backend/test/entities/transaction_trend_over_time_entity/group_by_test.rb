# frozen_string_literal: true

require 'test_helper'

class TransactionTrendOverTimeEntityGroupByTest < ActiveSupport::TestCase
  test 'should group transactions by day for spend category' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 6)
    params = { type: 'spend', group_by: 'day' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = {
      Date.new(2024, 7, 1) => 0,
      Date.new(2024, 7, 2) => 9.99,
      Date.new(2024, 7, 3) => 17.35,
      Date.new(2024, 7, 4) => 0,
      Date.new(2024, 7, 5) => 0,
      Date.new(2024, 7, 6) => 0
    }

    assert_equal expected_result, result
  end

  test 'should group transactions by week for spend category' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 31)
    params = { type: 'spend', group_by: 'week' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = {
      Date.new(2024, 6, 30) => 27.34,
      Date.new(2024, 7, 7) => 0,
      Date.new(2024, 7, 14) => 0,
      Date.new(2024, 7, 21) => 0,
      Date.new(2024, 7, 28) => 0
    }

    assert_equal expected_result, result
  end

  test 'should group transactions by month for spend category' do
    start_date = Date.new(2024, 5, 1)
    end_date = Date.new(2024, 9, 30)
    params = { type: 'spend' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = {
      Date.new(2024, 5, 1) => 0,
      Date.new(2024, 6, 1) => 0,
      Date.new(2024, 7, 1) => 27.34,
      Date.new(2024, 8, 1) => 0,
      Date.new(2024, 9, 1) => 12.19
    }

    assert_equal expected_result, result
  end

  test 'should group transactions inclusive by month for spend category' do
    start_date = Date.new(2024, 5, 1)
    end_date = Date.new(2024, 8, 31)
    Transaction.create!(
      transaction_date: Date.new(2024, 8, 31),
      subcategory_id: subcategories(:restaurant).id,
      amount: 230.00,
      description: 'last date of range',
      account_id: accounts(:one).id
    )
    params = { type: 'spend', group_by: 'month' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = {
      Date.new(2024, 5, 1) => 0,
      Date.new(2024, 6, 1) => 0,
      Date.new(2024, 7, 1) => 27.34,
      Date.new(2024, 8, 1) => 230.00
    }

    assert_equal expected_result, result
  end

  test 'should group transactions by year for spend category' do
    start_date = Date.new(2022, 1, 1)
    end_date = Date.new(2024, 12, 31)
    params = { type: 'spend', group_by: 'year' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = {
      Date.new(2022, 1, 1) => 0,
      Date.new(2023, 1, 1) => 0,
      Date.new(2024, 1, 1) => 39.53
    }

    assert_equal expected_result, result
  end

  test 'should group transactions by day for income category' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 6)
    params = { type: 'income', group_by: 'day' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = {
      Date.new(2024, 7, 1) => 0,
      Date.new(2024, 7, 2) => 0,
      Date.new(2024, 7, 3) => 0,
      Date.new(2024, 7, 4) => 122.33,
      Date.new(2024, 7, 5) => 0,
      Date.new(2024, 7, 6) => 0
    }

    assert_equal expected_result, result
  end
end
