# frozen_string_literal: true

require 'test_helper'

module Transactions
  class SplitsControllerCreateTest < ActionDispatch::IntegrationTest
    test 'sync calls SyncSplits service with the correct arguments' do
      original_transaction = transactions(:with_split)
      split = transactions(:split)

      split_params = [
        {
          id: split.id,
          amount: 55.0,
          description: 'Updated split'
        },
        {
          amount: 30.0,
          description: 'New split',
          subcategory_id: original_transaction.subcategory_id
        }
      ]

      original_new = TransactionServices::SyncSplits.method(:new)

      TransactionServices::SyncSplits
        .expects(:new)
        .with do |arg1, arg2|
          arg1 == original_transaction &&
            arg2.is_a?(Array) &&
            arg2.all? { |p| p.is_a?(ActionController::Parameters) } &&
            arg2[0][:id] == split.id.to_s &&
            arg2[0][:amount] == '55.0' &&
            arg2[0][:description] == 'Updated split' &&
            arg2[1][:amount] == '30.0' &&
            arg2[1][:description] == 'New split' &&
            arg2[1][:subcategory_id] == original_transaction.subcategory_id.to_s
        end
        .returns(original_new.call(original_transaction, split_params))

      patch sync_splits_transaction_url(original_transaction.id),
            params: { splits: split_params }

      assert_response :created
    end

    test 'successful sync_splits returns the correct response' do
      original_transaction = transactions(:with_split)
      split = transactions(:split)

      split_params = [
        { id: split.id, amount: 55.0, description: 'Updated split' },
        { amount: 30.0, description: 'New split', subcategory_id: original_transaction.subcategory_id }
      ]

      patch sync_splits_transaction_url(original_transaction.id),
            params: { splits: split_params }

      assert_response :created
      result = response.parsed_body
      splits = original_transaction.reload.splits.sort_by(&:id)

      assert_includes result, :original
      assert_includes result, :splits

      assert_equal JSON.parse(TransactionSerializer.new(original_transaction).to_json), result[:original]

      serialized_splits = splits.map { |s| JSON.parse(TransactionSerializer.new(s).to_json) }
      assert_equal(serialized_splits, result[:splits].sort_by { |s| s[:id] })
    end

    test 'should return 404 when original transaction not found' do
      patch sync_splits_transaction_url(0), params: {
        splits: [
          { amount: 100.0, description: 'Split 1' }
        ]
      }

      assert_response :not_found
    end

    test 'should return not found when split id not found on original transaction' do
      original_transaction = transactions(:four)
      foreign_split = transactions(:split)

      split_params = [
        { id: foreign_split.id, description: 'Bad split' }
      ]

      patch sync_splits_transaction_url(original_transaction.id), params: {
        splits: split_params
      }

      assert_response :not_found
      expected_error = {
        'field' => 'splits',
        'message' => "ID(s) #{foreign_split.id} not found for original transaction"
      }

      assert_includes response.parsed_body['errors'], expected_error
    end

    test 'should error when split amount exceeds original amount' do
      original_transaction = transactions(:four)
      excess_amount = (original_transaction.amount.to_d / 2) + 1
      split_params = [
        { amount: excess_amount, description: 'Split 1' },
        { amount: excess_amount, description: 'Split 2' }
      ]

      patch sync_splits_transaction_url(original_transaction.id), params: {
        splits: split_params
      }

      assert_response :unprocessable_entity
      expected_error = {
        'field' => 'splits',
        'message' => 'splits total amount cannot exceed the original transaction amount'
      }

      assert_includes response.parsed_body['errors'], expected_error
    end

    test 'should error when split amount sign does not match original amount' do
      original_transaction = transactions(:four)
      split_amount = (original_transaction.amount.to_d / 2) - 1
      split_params = [
        { amount: split_amount, description: 'Split 1' },
        { amount: -split_amount, description: 'Split 2' }
      ]

      patch sync_splits_transaction_url(original_transaction.id), params: {
        splits: split_params
      }

      assert_response :unprocessable_entity
      expected_error = {
        'field' => 'splits',
        'message' => 'splits amounts must match the sign of the original transaction amount'
      }

      assert_includes response.parsed_body['errors'], expected_error
    end

    test 'should error when split param missing required field' do
      original_transaction = transactions(:four)
      split_params = [
        { amount: 1.0 }
      ]

      patch sync_splits_transaction_url(original_transaction.id), params: {
        splits: split_params
      }

      assert_response :unprocessable_entity
      expected_error = {
        'field' => 'description',
        'message' => 'description is required and must have a minimum of three characters'
      }

      assert_includes response.parsed_body['errors'], expected_error
    end

    test 'should error when split param missing amount field' do
      original_transaction = transactions(:four)
      split_params = [
        { description: 'missing amount', amount: -0.0 }
      ]

      patch sync_splits_transaction_url(original_transaction.id), params: {
        splits: split_params
      }

      assert_response :unprocessable_entity
      expected_error = {
        'field' => 'splits',
        'message' => 'splits amounts must match the sign of the original transaction amount'
      }

      assert_includes response.parsed_body['errors'], expected_error
    end
  end
end
