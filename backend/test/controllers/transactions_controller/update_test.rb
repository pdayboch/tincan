# frozen_string_literal: true

require 'test_helper'

class TransactionsControllerUpdateTest < ActionDispatch::IntegrationTest
  test 'should update transaction category' do
    transaction = transactions(:one)
    new_subcategory = subcategories(:unused_subcategory)

    patch transaction_url(transaction), params: {
      subcategory_name: new_subcategory.name
    }

    assert_response :success
    transaction.reload

    assert_equal new_subcategory.category.id, transaction.category_id, 'Category was not updated'
    assert_equal new_subcategory.id, transaction.subcategory_id, 'Subcategory was not updated'
  end

  test 'should error update with invalid subcategory' do
    transaction = transactions(:one)
    patch transaction_url(transaction), params: {
      subcategory_name: 'invalid subcategory'
    }

    assert_response :unprocessable_entity

    json_response = response.parsed_body
    expected_error = {
      'field' => 'subcategoryName',
      'message' => 'subcategoryName is invalid'
    }

    assert_includes json_response['errors'], expected_error
  end

  test 'should error update when transaction model has validation errors' do
    transaction = transactions(:one)

    patch transaction_url(transaction), params: { account_id: 0 }

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'account',
      'message' => 'account must exist'
    }

    assert_includes json_response['errors'], expected_error
  end

  test 'should update transaction amount and description' do
    transaction = transactions(:one)
    new_amount = 100.00
    new_description = 'a whole new transaction'

    assert_not_equal new_amount, transaction.amount, 'Amount not updated'
    assert_not_equal new_description, transaction.description, 'Description not updated'

    patch transaction_url(transaction), params: {
      amount: new_amount,
      description: new_description
    }

    assert_response :success
    transaction.reload

    assert_equal new_amount, transaction.amount, 'Amount not updated'
    assert_equal new_description, transaction.description, 'Description not updated'
  end
end
