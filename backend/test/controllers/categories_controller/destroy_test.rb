# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerDestroyTest < ActionDispatch::IntegrationTest
  test 'should destroy category' do
    category = categories(:unused_category)
    assert_difference('Category.count', -1) do
      delete category_url(category), as: :json
    end

    assert_response :no_content
  end

  test 'should raise bad_request error on destroy with transactions' do
    category = categories(:one)

    assert_not category.transactions.empty?, 'Category should have transactions for this test'

    assert_no_difference 'Category.count' do
      delete category_url(category), as: :json
    end

    assert_response :bad_request
    json_response = response.parsed_body
    expected_error_message = [{
      'field' => 'category',
      'message' => 'Cannot delete a category that has transactions associated with it'
    }]
    assert_equal expected_error_message, json_response['errors']
  end
end
