require "test_helper"

class Categorization::RulesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get categorization_rules_url
    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal CategorizationRule.count, json_response.size
  end

  test "should create rule" do
    subcategory = subcategories(:one)
    category = subcategory.category

    assert_difference('CategorizationRule.count') do
      post categorization_rules_url, params: {
        subcategoryId: subcategory.id
      }
    end
    assert_response :created
    json_response = JSON.parse(response.body)

    assert_equal json_response['subcategoryId'], subcategory.id
    assert_equal json_response['categoryId'], category.id
  end

  test "should render create errors when model is invalid" do
    assert_no_difference('CategorizationRule.count') do
      post categorization_rules_url, params: {}
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    expected_error = {
      'field' => 'subcategory',
      'message' => 'subcategory must exist'
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should render create errors when categoryId is included" do
    assert_no_difference('CategorizationCondition.count') do
      post categorization_rules_url, params: {
        categoryId: 1,
        subcategoryId: 2
      }
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    expected_error = {
      'field' => 'categoryId',
      'message' =>  'categoryId parameter is not accepted. Please set the subcategoryId, and the category will be inferred automatically.'
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should update rule" do
    rule = categorization_rules(:one)
    new_subcategory = subcategories(:unused_subcategory)

    patch categorization_rule_url(rule), params: {
      subcategoryId: new_subcategory.id
    }
    assert_response :success

    rule.reload
    assert_equal rule.subcategory_id, new_subcategory.id
  end

  test "should render update errors when model is invalid" do
    rule = categorization_rules(:one)
    assert_no_difference('CategorizationRule.count') do
      patch categorization_rule_url(rule), params: { subcategoryId: 0 }
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    expected_error = {
      'field' => 'subcategory',
      'message' => 'subcategory must exist'
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should render update errors when categoryId is included" do
    rule = categorization_rules(:one)

    patch categorization_rule_url(rule), params: {
      categoryId: 1
    }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    expected_error = {
      'field' => 'categoryId',
      'message' =>  'categoryId parameter is not accepted. Please set the subcategoryId, and the category will be inferred automatically.'
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should destroy rule" do
    rule = categorization_rules(:one)
    conditions_count = rule.categorization_conditions.count

    assert_difference('CategorizationCondition.count', -conditions_count) do
      delete categorization_rule_url(rule)
    end

    assert_response :no_content
  end
end
