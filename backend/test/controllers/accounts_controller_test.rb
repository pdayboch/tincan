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
    assert_difference('Account.count') do
      post accounts_url, params: {
        accountProvider: 'ChaseFreedomCreditCard',
        userId: @account.user_id,
        statementDirectory: 'credit cards/chase'
      }
    end

    assert_response :created
  end

  test "should return error with invalid accountProvider create account" do
    post accounts_url, params: {
      accountProvider: 'NonExistantProvider',
      userId: @account.user_id,
      statementDirectory: 'credit cards/chase'
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    expected_error = {
      'field' => 'accountProvider',
      'message' =>  "accountProvider 'NonExistantProvider' is not a valid value."
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should update account" do
    patch account_url(@account), params: {
      active: false,
      statementDirectory: 'credit cards/new'
    }

    assert_response :success
    @account.reload
    assert_equal @account.active, false, 'Account was not updated'
    assert_equal @account.statement_directory, 'credit cards/new', 'Account was not updated'
  end

  test "should return error when updating account with disallowed params" do
    patch account_url(@account), params: { accountProvider: 'BarclaysViewCreditCard' }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    expected_error = {
      'field' => 'accountProvider',
      'message' => 'accountProvider cannot be updated after account creation.'
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should destroy account" do
    assert_difference('Account.count', -1) do
      delete account_url(@account), as: :json
    end

    assert_response :no_content
  end
end
