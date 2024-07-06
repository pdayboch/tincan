require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:one)
  end

  test "should get index" do
    get transactions_url, as: :json
    assert_response :success
  end

  class CreateTransactionTest < TransactionsControllerTest
    test "should create transaction" do
      assert_difference("Transaction.count") do
        post transactions_url,
          params: {
            transaction: {
              account_id: @transaction.account_id,
              amount: @transaction.amount,
              category: categories(:one).name,
              description: @transaction.description,
              statement_id: @transaction.statement_id,
              subcategory: subcategories(:one).name,
              transaction_date: @transaction.transaction_date,
            },
          }, as: :json
      end

      assert_response :success
    end

    test "with no category and no subcategory should create transaction with default" do
      assert_difference("Transaction.count") do
        post transactions_url,
          params: {
            transaction: {
              account_id: @transaction.account_id,
              amount: @transaction.amount,
              description: @transaction.description,
              statement_id: @transaction.statement_id,
              transaction_date: @transaction.transaction_date,
            },
          }, as: :json
      end

      assert_response :success
      category_id = JSON.parse(response.body)["category_id"]
      subcategory_id = JSON.parse(response.body)["subcategory_id"]
      assert_equal "Uncategorized", Category.find(category_id).name
      assert_equal "Uncategorized", Subcategory.find(subcategory_id).name
    end

    test "should error with invalid category" do
      assert_no_difference("Transaction.count") do
        post transactions_url,
          params: {
            transaction: {
              account_id: @transaction.account_id,
              amount: @transaction.amount,
              category: "invalid category",
              description: @transaction.description,
              statement_id: @transaction.statement_id,
              subcategory: subcategories(:one).name,
              transaction_date: @transaction.transaction_date,
            },
          }, as: :json
      end

      assert_response :unprocessable_entity
      error_response = JSON.parse(response.body)
      assert_equal "is invalid", error_response["category"].first
    end

    test "should error with invalid subcategory" do
      assert_no_difference("Transaction.count") do
        post transactions_url,
          params: {
            transaction: {
              account_id: @transaction.account_id,
              amount: @transaction.amount,
              category: categories(:one).name,
              description: @transaction.description,
              statement_id: @transaction.statement_id,
              subcategory: "invalid subcategory",
              transaction_date: @transaction.transaction_date,
            },
          }, as: :json
      end

      assert_response :unprocessable_entity
      error_response = JSON.parse(response.body)
      assert_equal "is invalid", error_response["subcategory"].first
    end
  end

  class UpdateTransactionTest < TransactionsControllerTest
    test "should update transaction category" do
      new_category = categories(:unused_category)
      new_subcategory = subcategories(:unused_subcategory)

      patch transaction_url(@transaction),
        params: {
          transaction: {
            category: new_category.name,
            subcategory: new_subcategory.name,
          },
        }, as: :json

      assert_response :success
      @transaction.reload # Reload the transaction from database to get the updated values
      assert_equal new_category.id, @transaction.category_id, "Category was not updated"
      assert_equal new_subcategory.id, @transaction.subcategory_id, "Subcategory was not updated"
    end

    test "should update transaction amount and description" do
      new_amount = 100.00
      new_description = "a whole new transaction"

      assert_not_equal new_amount,
        @transaction.amount,
        "Amount should be different for this test"
      assert_not_equal new_description,
        @transaction.description,
        "Description should be different for this test"

      patch transaction_url(@transaction),
        params: {
          transaction: {
            amount: new_amount,
            description: new_description,
          },
        }, as: :json

      assert_response :success
      @transaction.reload # Reload the transaction from database to get the updated values
      assert_equal new_amount, @transaction.amount, "Amount was not updated"
      assert_equal new_description, @transaction.description, "Description was not updated"
    end
  end

  test "should destroy transaction" do
    assert_difference("Transaction.count", -1) do
      delete transaction_url(@transaction), as: :json
    end

    assert_response :no_content
  end
end
