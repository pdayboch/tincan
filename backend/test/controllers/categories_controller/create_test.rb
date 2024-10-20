# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerCreateTest < ActionDispatch::IntegrationTest
  test 'should create category' do
    assert_difference('Category.count') do
      post categories_url, params: {
        name: 'new category',
        categoryType: 'spend'
      }
    end

    assert_response :created
  end

  test 'should raise error on create with duplicate name' do
    existing_category = categories(:income)

    assert_no_difference('Category.count') do
      post categories_url, params: {
        name: existing_category.name,
        categoryType: 'spend'
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

  test 'should raise error on create without type' do
    assert_no_difference('Category.count') do
      post categories_url, params: {
        name: 'new category'
      }
    end

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'categoryType',
      'message' => "categoryType can't be blank"
    }
    assert_includes json_response['errors'], expected_error
  end

  test 'should raise error on create with invalid type' do
    assert_no_difference('Category.count') do
      post categories_url, params: {
        name: 'new category',
        categoryType: 'nonsense'
      }
    end

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'categoryType',
      'message' => "categoryType 'nonsense' is invalid"
    }
    assert_includes json_response['errors'], expected_error
  end
end
