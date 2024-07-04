require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:one)
  end

  test "should get index" do
    get transactions_url, as: :json
    assert_response :success
  end

  test "should create transaction" do
    assert_difference("Transaction.count") do
      post transactions_url, params: { transaction: { account_id: @transaction.account_id, amount: @transaction.amount, category_id: @transaction.category_id, description: @transaction.description, statement_id: @transaction.statement_id, subcategory_id: @transaction.subcategory_id, transaction_date: @transaction.transaction_date } }, as: :json
    end

    assert_response :created
  end

  test "should update transaction" do
    patch transaction_url(@transaction), params: { transaction: { account_id: @transaction.account_id, amount: @transaction.amount, category_id: @transaction.category_id, description: @transaction.description, statement_id: @transaction.statement_id, subcategory_id: @transaction.subcategory_id, transaction_date: @transaction.transaction_date } }, as: :json
    assert_response :success
  end

  test "should destroy transaction" do
    assert_difference("Transaction.count", -1) do
      delete transaction_url(@transaction), as: :json
    end

    assert_response :no_content
  end
end
