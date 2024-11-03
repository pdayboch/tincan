# frozen_string_literal: true

require 'test_helper'

class TransactionDataEntityValidateParamsTest < ActiveSupport::TestCase
  test 'initialize raises error when page_size is invalid' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(page_size: 2)
    end

    assert_raises BadRequestError do
      TransactionDataEntity.new(page_size: 1001)
    end
  end

  test 'initialize raises error when sort_by is invalid' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(sort_by: 'invalid_sort_by')
    end
  end

  test 'initialize raises error when sort_direction is invalid' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(sort_direction: 'invalid_direction')
    end
  end

  test 'initialize raises error when starting_after is invalid for transaction_date' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(sort_by: 'transaction_date', starting_after: 'invalid_token')
    end
  end

  test 'initialize raises error when starting_after is invalid for amount' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(sort_by: 'amount', starting_after: 'invalid_token')
    end
  end

  test 'initialize raises error when ending_before is invalid for transaction_date' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(sort_by: 'transaction_date', ending_before: 'invalid_token')
    end
  end

  test 'initialize raises error when ending_before is invalid for amount' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(sort_by: 'amount', ending_before: 'invalid_token')
    end
  end

  test 'initialize raises error when starting_after and ending_before are both populated' do
    assert_raises BadRequestError do
      TransactionDataEntity.new(starting_after: '2024-09-01.123', ending_before: '2024-09-02.345')
    end
  end
end
