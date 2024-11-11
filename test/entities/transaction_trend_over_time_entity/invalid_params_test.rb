# frozen_string_literal: true

require 'test_helper'

class TransactionTrendOverTimeEntityInvalidParamsTest < ActiveSupport::TestCase
  test 'should raise error for invalid type param' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 6)
    params = { type: 'invalid_type', group_by: 'day' }

    assert_raises BadRequestError do
      TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    end
  end

  test 'should raise error for invalid group_by param' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 7, 6)
    params = { type: 'spend', group_by: 'invalid_group_by' }

    assert_raises BadRequestError do
      TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    end
  end

  test 'should raise error when end_date before start_date' do
    start_date = Date.new(2024, 7, 1)
    end_date = Date.new(2024, 5, 6)
    params = { type: 'spend' }

    assert_raises BadRequestError do
      TransactionTrendOverTimeEntity.new(start_date, end_date, params)
    end
  end
end
