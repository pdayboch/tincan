# frozen_string_literal: true

require 'test_helper'

class TransactionSplitDataEntityTest < ActiveSupport::TestCase
  test 'data returns correct serialized transaction and splits' do
    original = transactions(:with_split)
    split = transactions(:split)

    entity = TransactionSplitDataEntity.new(original)
    result = entity.data

    assert_equal TransactionSerializer.new(original).as_json, result[:original]
    assert_equal 1, result[:splits].count
    assert_equal TransactionSerializer.new(split).as_json, result[:splits].first
  end

  test 'data returns correct serialized for transaction without splits' do
    original = transactions(:one)

    entity = TransactionSplitDataEntity.new(original)
    result = entity.data

    assert_equal TransactionSerializer.new(original).as_json, result[:original]
    assert_equal 0, result[:splits].count
  end
end
