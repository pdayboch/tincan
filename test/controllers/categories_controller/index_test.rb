# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerIndexTest < ActionDispatch::IntegrationTest
  test 'should get index from CategoryDataEntity' do
    original_new = CategoryDataEntity.method(:new)

    CategoryDataEntity
      .expects(:new)
      .returns(original_new.call)

    get categories_url

    assert_response :success

    json_response = response.parsed_body
    assert json_response['totalItems'].present?
    assert json_response['filteredItems'].present?
    assert json_response['categories'].present?
  end
end
