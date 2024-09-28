# frozen_string_literal: true

require 'test_helper'

class TransactionsControllerDestroyTest < ActionDispatch::IntegrationTest
  test 'should destroy transaction' do
    transaction = transactions(:one)
    assert_difference('Transaction.count', -1) do
      delete transaction_url(transaction), as: :json
    end

    assert_response :no_content
  end
end
