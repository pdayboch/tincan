# frozen_string_literal: true

require 'test_helper'

class TransactionsControllerCreateTest < ActionDispatch::IntegrationTest
  test 'should create transaction' do
    subcategory = subcategories(:paycheck)
    account = accounts(:one)
    statement = statements(:one)

    assert_difference('Transaction.count') do
      post transactions_url, params: {
        accountId: account.id,
        amount: 15.00,
        description: 'coffee bar',
        statementId: statement.id,
        subcategoryId: subcategory.id,
        transactionDate: '2024-09-14'
      }
    end

    assert_response :success

    json_response = response.parsed_body
    category_name = json_response['category']['name']
    subcategory_name = json_response['subcategory']['name']

    assert_equal subcategory.category.name, category_name
    assert_equal subcategory.name, subcategory_name
  end

  test 'should error create with invalid subcategory' do
    account = accounts(:one)

    assert_no_difference('Transaction.count') do
      post transactions_url, params: {
        accountId: account.id,
        amount: 30.00,
        description: 'the store',
        subcategoryId: 0,
        transactionDate: '2024-09-14'
      }
    end

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'subcategoryId',
      'message' => 'subcategoryId is invalid'
    }

    assert_includes json_response['errors'], expected_error
  end

  test 'should error create when transaction model has validation errors' do
    subcategory = subcategories(:paycheck)
    # Mock the transaction to return errors when saved
    transaction = Transaction.new(
      subcategory: subcategory,
      description: 'bad transaction because missing account',
      amount: 14.99,
      transaction_date: '2024-09-15'
    )

    # Stub the controller's new transaction with the invalid one.
    Transaction.stubs(:new).returns(transaction)

    post transactions_url, params: { subcategory_name: subcategory.name }

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'account',
      'message' => 'account must exist'
    }

    assert_includes json_response['errors'], expected_error
  end
end
