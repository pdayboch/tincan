# frozen_string_literal: true

require 'test_helper'

module Transactions
  class SplitsControllerShowTest < ActionDispatch::IntegrationTest
    test 'show calls TransactionSplitDataEntity with the correct argument' do
      original_transaction = transactions(:with_split)

      original_new = TransactionSplitDataEntity.method(:new)

      TransactionSplitDataEntity
        .expects(:new)
        .with { |arg| arg.is_a?(Transaction) && arg.id == original_transaction.id }
        .returns(original_new.call(original_transaction))

      get splits_transaction_url(original_transaction.id)

      assert_response :success
    end

    test 'show returns the correct data' do
      original_transaction = transactions(:with_split)
      split = transactions(:split)

      get splits_transaction_url(original_transaction.id)
      result = response.parsed_body

      assert_includes result, :original
      assert_includes result, :splits

      assert_equal JSON.parse(TransactionSerializer.new(original_transaction).to_json), result[:original]
      assert_equal JSON.parse(TransactionSerializer.new(split).to_json), result[:splits][0]
    end
  end
end
