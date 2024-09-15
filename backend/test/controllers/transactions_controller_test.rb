require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
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

  test 'should create transaction' do
    subcategory = subcategories(:one)
    account = accounts(:one)
    statement = statements(:one)

    assert_difference('Transaction.count') do
      post transactions_url, params: {
        accountId: account.id,
        amount: 15.00,
        description: 'coffee bar',
        statementId: statement.id,
        subcategoryName: subcategory.name,
        transactionDate: '2024-09-14'
      }
    end

    assert_response :success
    category_name = JSON.parse(response.body)['category']['name']
    subcategory_name = JSON.parse(response.body)['subcategory']['name']

    assert_equal subcategory.category.name, category_name
    assert_equal subcategory.name, subcategory_name
  end

  test 'should error create with invalid subcategory' do
    account = accounts(:one)

    assert_no_difference('Transaction.count') do
      post transactions_url, params: {
        account_id: account.id,
        amount: 30.00,
        description: 'the store',
        subcategory_name: 'invalid subcategory',
        transaction_date: '2024-09-14'
      }
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    expected_error = {
      'field' => 'subcategoryName',
      'message' => 'subcategoryName is invalid'
    }

    assert_includes json_response['errors'], expected_error
  end

  test 'should error create when transaction model has validation errors' do
    subcategory = subcategories(:one)
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
    json_response = JSON.parse(response.body)
    expected_error = {
      'field' => 'account',
      'message' => 'account must exist'
    }

    assert_includes json_response['errors'], expected_error
  end

  test 'should update transaction category' do
    transaction = transactions(:one)
    new_subcategory = subcategories(:unused_subcategory)

    patch transaction_url(transaction), params: {
      subcategory_name: new_subcategory.name
    }

    assert_response :success
    transaction.reload # Reload the transaction from database to get the updated values

    assert_equal new_subcategory.category.id, transaction.category_id, 'Category was not updated'
    assert_equal new_subcategory.id, transaction.subcategory_id, 'Subcategory was not updated'
  end

  test 'should error update with invalid subcategory' do
    transaction = transactions(:one)
    assert_no_difference('Transaction.count') do
      patch transaction_url(transaction), params: {
        subcategory_name: 'invalid subcategory',
      }
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
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
    json_response = JSON.parse(response.body)
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
      description: new_description,
    }

    assert_response :success
    transaction.reload # Reload the transaction from database to get the updated values

    assert_equal new_amount, transaction.amount, 'Amount not updated'
    assert_equal new_description, transaction.description, 'Description not updated'
  end

  test 'should destroy transaction' do
    transaction = transactions(:one)
    assert_difference('Transaction.count', -1) do
      delete transaction_url(transaction), as: :json
    end

    assert_response :no_content
  end
end
