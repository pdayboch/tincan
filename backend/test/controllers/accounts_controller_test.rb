require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
  end

  test "should get index" do
    get accounts_url, as: :json
    assert_response :success
  end

  test "should create account" do
    assert_difference("Account.count") do
      post accounts_url, params: { accountProvider: "ChaseFreedomCreditCard", userId: @account.user_id, statementDirectory: "credit cards/chase" }, as: :json
    end

    assert_response :created
  end

  test "should return error with invalid accountProvider create account" do
    post accounts_url, params: { accountProvider: "NonExistantProvider", userId: @account.user_id, statementDirectory: "credit cards/chase" }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "Invalid accountProvider: NonExistantProvider", "Error message should include 'Invalid statement parser class'"
  end

  test "should update account" do
    patch account_url(@account), params: { active: false, statementDirectory: "credit cards/new" }, as: :json

    assert_response :success
    @account.reload
    assert_equal @account.active, false, "Account was not updated"
    assert_equal @account.statement_directory, "credit cards/new", "Account was not updated"
  end

  test "should return error when updating account with disallowed params" do
    patch account_url(@account), params: { accountProvider: "BarclaysViewCreditCard" }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["error"], "account_provider", "Error message should include 'account_provider'"
  end

  test "should destroy account" do
    assert_difference("Account.count", -1) do
      delete account_url(@account), as: :json
    end

    assert_response :no_content
  end
end
