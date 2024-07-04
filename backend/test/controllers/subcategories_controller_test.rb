require "test_helper"

class SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subcategory = subcategories(:one)
  end

  test "should create subcategory" do
    assert_difference("Subcategory.count") do
      post subcategories_url, params: { subcategory: { category_id: @subcategory.category_id, name: "New subcategory" } }, as: :json
    end

    assert_response :created
  end

  test "should update subcategory" do
    patch subcategory_url(@subcategory), params: { subcategory: { category_id: @subcategory.category_id, name: @subcategory.name } }, as: :json
    assert_response :success
  end

  test "should destroy subcategory" do
    subcategory = subcategories(:unused_subcategory)
    assert_difference("Subcategory.count", -1) do
      delete subcategory_url(subcategory), as: :json
    end

    assert_response :no_content
  end
end
