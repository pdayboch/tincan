# frozen_string_literal: true

require 'test_helper'

class TransactionsControllerIndexTest < ActionDispatch::IntegrationTest
  test 'should get index from TransactionDataEntity' do
    TransactionDataEntity
      .any_instance
      .expects(:get_data)
      .returns({ some_key: 'some_value' })

    get transactions_url

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'some_value', json_response['some_key']
  end

  test 'should get index from TransactionDataEntity with accounts filter' do
    TransactionDataEntity
      .expects(:new)
      .with({ 'accounts' => %w[44 46] })
      .returns(mock(get_data: { some_key: 'some_value' }))

    get transactions_url, params: { accounts: %w[44 46] }

    assert_response :success
  end

  test 'should get index from TransactionDataEntity with users filter' do
    TransactionDataEntity
      .expects(:new)
      .with({ 'users' => %w[44 46] })
      .returns(mock(get_data: { some_key: 'some_value' }))

    get transactions_url, params: { users: %w[44 46] }

    assert_response :success
  end

  test 'should get index from TransactionDataEntity and drop invalid filters' do
    TransactionDataEntity
      .expects(:new)
      .with({})
      .returns(mock(get_data: { some_key: 'some_value' }))

    get transactions_url, params: { fooBear: '123' }

    assert_response :success
  end
end
