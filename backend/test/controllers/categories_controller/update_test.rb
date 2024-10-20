# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerUpdateTest < ActionDispatch::IntegrationTest
  test 'should update category name' do
    category = categories(:one)
    old_type = category.category_type

    patch category_url(category), params: {
      name: 'new name'
    }
    assert_response :success

    json_response = response.parsed_body
    assert_equal json_response['name'], 'new name'
    assert_equal json_response['categoryType'], old_type
    assert_equal category.reload.name, 'new name'
    assert_equal category.reload.category_type, old_type
  end

  test 'should update category_type' do
    category = categories(:transfer)
    old_name = category.name

    patch category_url(category), params: {
      categoryType: 'spend'
    }
    assert_response :success

    json_response = response.parsed_body
    assert_equal json_response['name'], old_name
    assert_equal json_response['categoryType'], 'spend'
    assert_equal category.reload.name, old_name
    assert_equal category.reload.category_type, 'spend'
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

  test 'should raise error on update with invalid category_type' do
    category = categories(:one)

    put category_url(category), params: {
      categoryType: 'nonsense'
    }

    assert_response :unprocessable_entity
    json_response = response.parsed_body
    expected_error = {
      'field' => 'categoryType',
      'message' => "categoryType 'nonsense' is invalid"
    }
    assert_includes json_response['errors'], expected_error
  end
end
