# frozen_string_literal: true

require 'test_helper'

module TransactionServices
  class SyncSplitsTest < ActiveSupport::TestCase
    test 'successfully syncs splits by creating, updating, and deleting splits' do
      original = transactions(:with_split)
      split = transactions(:split)
      split_to_delete = original.splits.create!(
        transaction_date: Date.new(2024, 10, 31),
        amount: 10.00,
        description: 'Split to delete',
        subcategory_id: original.subcategory_id,
        account_id: original.account_id
      )

      assert_equal 2, original.splits.count

      split_params = [
        { id: split.id, amount: 55.0, description: 'Updated split' },
        { amount: 30.0, description: 'New split', subcategory_id: original.subcategory_id }
      ]

      service = SyncSplits.new(original, split_params)
      service.call
      splits = original.reload.splits

      assert_equal 2, splits.count

      # Verify updated split attributes
      assert_equal 55.0, split.reload.amount
      assert_equal 'Updated split', split.description

      # Verify new split attributes
      new_split = splits.find_by(description: 'New split')
      assert_not_nil new_split
      assert_equal 30.0, new_split.amount
      assert_equal 'New split', new_split.description

      # ensure split_to_delete was destroyed
      assert_nil Transaction.find_by(id: split_to_delete.id)
    end

    test 'successfully updates split when id passed in as string instead of int' do
      original = transactions(:with_split)
      split = transactions(:split)

      split_params = [
        { id: split.id.to_s, amount: 20.00, description: 'Updated split' }
      ]

      service = SyncSplits.new(original, split_params)
      service.call

      assert_equal 'Updated split', split.reload.description
    end

    test 'successful new split adjusts the original amount correctly' do
      original = transactions(:four)
      original_amount = original.amount
      split_params = [
        { amount: 200.0, description: 'Split 1' },
        { amount: 100.0, description: 'Split 2' }
      ]

      service = SyncSplits.new(original, split_params)
      service.call

      expected_remaining_amount = original_amount.to_d - split_params.sum { |s| s[:amount].to_d }
      assert_equal expected_remaining_amount, original.reload.amount
    end

    test 'succesful update keeps original amount in sync' do
      original = transactions(:with_split)
      original_amount = original.amount
      split = transactions(:split)
      new_split_amount = split.amount + 5.0

      split_params = [
        { id: split.id, amount: new_split_amount }
      ]

      SyncSplits.new(original, split_params).call

      assert_equal original_amount - 5.0, original.reload.amount
    end

    test 'successful split returns the correct data' do
      original = transactions(:four)

      split_params = [
        { amount: 30.0, description: 'New Split', subcategory_id: original.subcategory_id }
      ]

      service = SyncSplits.new(original, split_params)
      result = service.call
      splits = original.reload.splits

      assert_includes result, :original
      assert_includes result, :splits

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
      service = SyncSplits.new(original, split_params)
      result = service.call

      assert original.has_splits
      assert(result[:splits].all? { |s| s[:splitFromId] == original.id })
    end

    test 'deleting all splits unsets the has_splits flag on original' do
      original = transactions(:with_split)
      split_params = []

      assert original.has_splits

      SyncSplits.new(original, split_params).call

      assert_not original.has_splits
    end

    test 'sets split transaction_date to the original when not specified' do
      original = transactions(:four)
      original_date = original.transaction_date

      split_params = [
        { amount: 50.0, description: 'Split without date', subcategory_id: original.subcategory_id }
      ]

      service = SyncSplits.new(original, split_params)
      service.call

      created_split = original.splits.last
      assert_equal original_date, created_split.transaction_date
    end

    test 'raises error if split param missing required field' do
      original = transactions(:four)

      split_params = [
        # missing description attribute
        { amount: original.amount - 1 }
      ]

      service = SyncSplits.new(original, split_params)

      assert_raises ActiveRecord::RecordInvalid do
        service.call
      end
    end

    test 'raises error if split id param does not exist for original transaction' do
      original = transactions(:four)
      foreign_split = transactions(:split) # doesn't belong to original

      split_params = [
        { id: foreign_split.id, amount: 20.00 }
      ]

      service = SyncSplits.new(original, split_params)

      assert_raises SyncSplits::SplitNotFoundError do
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

      service = SyncSplits.new(original, split_params)

      assert_raises SyncSplits::SplitAmountSignMismatchError do
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

      service = SyncSplits.new(original, split_params)

      assert_raises SyncSplits::SplitAmountExceedsOriginalError do
        service.call
      end
    end

    test 'raises error if any splits have a zero amount' do
      original = transactions(:four)

      split_params = [
        { amount: 1.00, description: 'Valid split 1', subcategory_id: original.subcategory_id },
        { amount: 0.00, description: 'invalid split with zero', subcategory_id: original.subcategory_id },
        { amount: 1.00, description: 'Valid split 2', subcategory_id: original.subcategory_id }
      ]

      service = SyncSplits.new(original, split_params)

      assert_raises SyncSplits::ZeroAmountSplitError do
        service.call
      end
    end

    test 'raises error if original transaction is nil' do
      split_params = [{ amount: 50.0, description: 'Split', subcategory_id: 1 }]

      assert_raises(ArgumentError, 'Original transaction cannot be nil') do
        TransactionServices::SyncSplits.new(nil, split_params)
      end
    end
  end
end
