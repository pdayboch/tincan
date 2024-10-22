# frozen_string_literal: true

require 'test_helper'

class TransactionTrendOverTimeEntityGroupByTest < ActiveSupport::TestCase
  test 'should group transactions by day for spend category' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 6)
    params = { type: 'spend', group_by: 'day' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = [
      { date: '2024-07-01', amount: 0 },
      { date: '2024-07-02', amount: 9.99 },
      { date: '2024-07-03', amount: 17.35 },
      { date: '2024-07-04', amount: 0 },
      { date: '2024-07-05', amount: 0 },
      { date: '2024-07-06', amount: 0 }
    ]

    assert_equal expected_result, result
  end

  test 'should group transactions by week for spend category' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 31)
    params = { type: 'spend', group_by: 'week' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = [
      { date: '2024-06-30', amount: 27.34 },
      { date: '2024-07-07', amount: 0 },
      { date: '2024-07-14', amount: 0 },
      { date: '2024-07-21', amount: 0 },
      { date: '2024-07-28', amount: 0 }
    ]

    assert_equal expected_result, result
  end

  test 'should group transactions by month for spend category' do
    start_date = Date.new(2024, 5, 1)
    end_date = Date.new(2024, 9, 30)
    params = { type: 'spend' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = [
      { date: '2024-05-01', amount: 0 },
      { date: '2024-06-01', amount: 0 },
      { date: '2024-07-01', amount: 27.34 },
      { date: '2024-08-01', amount: 0 },
      { date: '2024-09-01', amount: 12.19 }
    ]

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

    expected_result = [
      { date: '2024-05-01', amount: 0 },
      { date: '2024-06-01', amount: 0 },
      { date: '2024-07-01', amount: 27.34 },
      { date: '2024-08-01', amount: 230.00 }
    ]

    assert_equal expected_result, result
  end

  test 'should group transactions by year for spend category' do
    start_date = Date.new(2022, 1, 1)
    end_date = Date.new(2024, 12, 31)
    params = { type: 'spend', group_by: 'year' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = [
      { date: '2022-01-01', amount: 0 },
      { date: '2023-01-01', amount: 0 },
      { date: '2024-01-01', amount: 39.53 }
    ]

    assert_equal expected_result, result
  end

  test 'should group transactions by day for income category' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 6)
    params = { type: 'income', group_by: 'day' }

    entity = TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    result = entity.data

    expected_result = [
      { date: '2024-07-01', amount: 0 },
      { date: '2024-07-02', amount: 0 },
      { date: '2024-07-03', amount: 0 },
      { date: '2024-07-04', amount: 122.33 },
      { date: '2024-07-05', amount: 0 },
      { date: '2024-07-06', amount: 0 }
    ]

    assert_equal expected_result, result
  end
end
