# frozen_string_literal: true

require 'test_helper'

class TransactionsControllerIndexTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get transactions_url

    assert_response :success

    json_response = response.parsed_body
    assert json_response['transactions'].is_a?(Array), 'Expected transactions to be an array'
    assert json_response['meta'].present?, 'Expected meta data to be present'
  end

  test 'should get index from TransactionDataEntity with accounts filter' do
    # Capture the original TransactionDataEntity.new method
    original_new = TransactionDataEntity.method(:new)

    # Expect the correct parameters and call the original constructor
    TransactionDataEntity
      .expects(:new)
      .with do |params|
        params.is_a?(ActionController::Parameters) && params[:accounts] == %w[44 46]
      end
      .returns(original_new.call(accounts: %w[44 46]))

    get transactions_url, params: { accounts: %w[44 46] }

    assert_response :success

    json_response = response.parsed_body
    assert json_response['transactions'].is_a?(Array), 'Expected transactions to be an array'
    assert json_response['meta'].present?, 'Expected meta data to be present'
  end

  test 'should get index from TransactionDataEntity with users filter' do
    # Capture the original TransactionDataEntity.new method
    original_new = TransactionDataEntity.method(:new)

    # Expect the correct parameters and call the original constructor
    TransactionDataEntity
      .expects(:new)
      .with do |params|
        params.is_a?(ActionController::Parameters) && params[:users] == %w[44 46]
      end
      .returns(original_new.call(users: %w[44 46]))

    get transactions_url, params: { users: %w[44 46] }

    assert_response :success

    json_response = response.parsed_body
    assert json_response['transactions'].is_a?(Array), 'Expected transactions to be an array'
    assert json_response['meta'].present?, 'Expected meta data to be present'
  end

  test 'should get index from TransactionDataEntity and drop invalid filters' do
    # Capture the original TransactionDataEntity.new method
    original_new = TransactionDataEntity.method(:new)

    # Expect the correct parameters and call the original constructor
    TransactionDataEntity
      .expects(:new)
      .with do |params|
        params.is_a?(ActionController::Parameters) && params.keys.empty?
      end
      .returns(original_new.call)

    get transactions_url, params: { fooBear: '123' }

    assert_response :success

    json_response = response.parsed_body
    assert json_response['transactions'].is_a?(Array), 'Expected transactions to be an array'
    assert json_response['meta'].present?, 'Expected meta data to be present'
  end
end
