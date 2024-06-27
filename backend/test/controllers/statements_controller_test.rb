require "test_helper"

class StatementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @statement = statements(:one)
  end

  test "should get index" do
    get statements_url, as: :json
    assert_response :success
  end

  test "should create statement" do
    assert_difference("Statement.count") do
      post statements_url, params: { statement: { account_id: @statement.account_id, statement_balance: @statement.statement_balance, statement_date: @statement.statement_date } }, as: :json
    end

    assert_response :created
  end

  test "should show statement" do
    get statement_url(@statement), as: :json
    assert_response :success
  end

  test "should update statement" do
    patch statement_url(@statement), params: { statement: { account_id: @statement.account_id, statement_balance: @statement.statement_balance, statement_date: @statement.statement_date } }, as: :json
    assert_response :success
  end

  test "should destroy statement" do
    assert_difference("Statement.count", -1) do
      delete statement_url(@statement), as: :json
    end

    assert_response :no_content
  end
end
