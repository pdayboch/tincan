# frozen_string_literal: true

require 'test_helper'

class SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  test 'should create subcategory' do
    category = categories(:one)
    assert_difference('Subcategory.count') do
      post subcategories_url, params: {
        category_id: category.id,
        name: 'New subcategory'
      }
    end

    assert_response :created

    json_response = response.parsed_body
    assert json_response['id'].present?
    assert_equal 'New subcategory', json_response['name']
    assert_equal category.id, json_response['categoryId']
    assert_equal false, json_response['hasTransactions']
  end

  test 'should raise error on create with duplicate name' do
    category = categories(:two)
    existing_subcategory = subcategories(:one)

    assert_no_difference('Subcategory.count') do
      post subcategories_url, params: {
        category_id: category.id,
        name: existing_subcategory.name
      }
    end

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'name',
      'message' => 'name already exists'
    }
    assert_includes json_response['errors'], expected_error
  end

  test 'should update subcategory' do
    subcategory = subcategories(:one)
    patch subcategory_url(subcategory), params: {
      category_id: subcategory.category_id,
      name: subcategory.name
    }
    assert_response :success
  end

  test 'should raise error on update with duplicate name' do
    subcategory = subcategories(:one)
    other_subcategory = subcategories(:two)

    put subcategory_url(subcategory), params: {
      name: other_subcategory.name
    }

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'name',
      'message' => 'name already exists'
    }
    assert_includes json_response['errors'], expected_error
  end

  test 'should destroy subcategory' do
    subcategory = subcategories(:unused_subcategory)
    assert_difference('Subcategory.count', -1) do
      delete subcategory_url(subcategory)
    end

    assert_response :no_content
  end

  test 'should raise bad_request error on destroy with transactions' do
    subcategory = subcategories(:one)

    assert_not subcategory.transactions.empty?, 'Subcategory should have transactions for this test'

    assert_no_difference 'Subcategory.count' do
      delete subcategory_url(subcategory)
    end

    assert_response :bad_request
    json_response = response.parsed_body
    expected_error_message = [{
      'field' => 'subcategory',
      'message' => 'Cannot delete a subcategory that has transactions associated with it'
    }]
    assert_equal expected_error_message, json_response['errors']
  end
end
