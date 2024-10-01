# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index from CategoryDataEntity' do
    original_new = CategoryDataEntity.method(:new)

    CategoryDataEntity
      .expects(:new)
      .returns(original_new.call)

    get categories_url

    assert_response :success

    json_response = response.parsed_body
    assert json_response['total_items'].present?
    assert json_response['filtered_items'].present?
    assert json_response['categories'].present?
  end

  test 'should create category' do
    assert_difference('Category.count') do
      post categories_url, params: {
        name: 'new category'
      }
    end

    assert_response :created
  end

  test 'should raise error on create with duplicate name' do
    existing_category = categories(:one)

    assert_no_difference('Category.count') do
      post categories_url, params: {
        name: existing_category.name
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

  test 'should update category' do
    category = categories(:one)
    patch category_url(category), params: {
      name: 'new name'
    }
    assert_response :success

    json_response = response.parsed_body
    assert_equal json_response['name'], 'new name'
    assert_equal category.reload.name, 'new name'
  end

  test 'should raise error on update with duplicate name' do
    category = categories(:one)
    other_category = categories(:two)

    put category_url(category), params: {
      name: other_category.name
    }

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'name',
      'message' => 'name already exists'
    }
    assert_includes json_response['errors'], expected_error
  end

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
