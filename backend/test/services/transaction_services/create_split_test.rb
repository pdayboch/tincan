# frozen_string_literal: true

require 'test_helper'

module TransactionServices
  class CreateSplitTest < ActiveSupport::TestCase
    test 'successful split returns the correct response' do
      original = transactions(:four)
      subcategory = subcategories(:restaurant)
      split_params = [
        { amount: 40.0, description: 'Split 1', subcategory_id: subcategory.id },
        { amount: 30.0, description: 'Split 2', subcategory_id: subcategory.id }
      ]

      service = CreateSplit.new(original, split_params)
      result = service.call
      splits = original.reload.splits

      assert_includes result, :original
      assert_includes result, :splits
      assert_equal 2, result[:splits].count

      assert_equal TransactionSerializer.new(original).as_json, result[:original]

      serialized_splits = splits.map { |s| TransactionSerializer.new(s).as_json }
      assert_equal(serialized_splits.sort_by { |s| s[:id] }, result[:splits].sort_by { |s| s[:id] })
    end

    test 'successful split sets the has_splits flag on original' do
      original = transactions(:four)
      split_params = [
        { amount: 100.0, description: 'Split', subcategory_id: original.subcategory_id }
      ]

      assert_not original.has_splits
      service = CreateSplit.new(original, split_params)
      result = service.call

      assert original.has_splits
      assert(result[:splits].all? { |s| s[:splitFromId] == original.id })
    end

    test 'successful split adjusts the original amount correctly' do
      original = transactions(:four)
      original_amount = original.amount
      split_params = [
        { amount: 200.0, description: 'Split 1' },
        { amount: 100.0, description: 'Split 2' }
      ]

      service = CreateSplit.new(original, split_params)
      service.call

      expected_remaining_amount = original_amount.to_d - split_params.sum { |s| s[:amount].to_d }
      assert_equal expected_remaining_amount, original.reload.amount
    end

    test 'sets transaction_date to the original transaction when not specified' do
      original = transactions(:four)
      original_date = original.transaction_date

      split_params = [
        { amount: 50.0, description: 'Split without date', subcategory_id: original.subcategory_id }
      ]

      service = CreateSplit.new(original, split_params)
      service.call

      created_split = original.splits.last
      assert_equal original_date, created_split.transaction_date
    end

    test 'raises error if split param missing required field' do
      original = transactions(:four)

      split_params = [
        { amount: original.amount - 1 }
      ]

      service = CreateSplit.new(original, split_params)

      assert_raises ActiveRecord::RecordInvalid do
        service.call
      end
    end

    test 'raises error if split amounts do not match original transaction sign' do
      original = transactions(:four)
      split_amount = (original.amount.to_d / 2) - 1

      split_params = [
        { amount: split_amount, description: 'Split 1' },
        { amount: -split_amount, description: 'Split 2' }
      ]

      service = CreateSplit.new(original, split_params)

      assert_raises CreateSplit::SplitAmountSignMismatchError do
        service.call
      end
    end

    test 'raises error if split amounts exceed original transaction amount' do
      original = transactions(:four)
      excess_amount = (original.amount.to_d / 2) + 1
      split_params = [
        { amount: excess_amount, description: 'Split 1' },
        { amount: excess_amount, description: 'Split 2' }
      ]

      service = CreateSplit.new(original, split_params)

      assert_raises CreateSplit::SplitAmountExceedsOriginalError do
        service.call
      end
    end

    test 'raises error if original transaction is nil' do
      split_params = [{ amount: 50.0, description: 'Split', subcategory_id: 1 }]

      assert_raises(ArgumentError, 'Original transaction cannot be nil') do
        TransactionServices::CreateSplit.new(nil, split_params)
      end
    end
  end
end
