require "test_helper"

class Categorization::ConditionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get categorization_conditions_url
    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal CategorizationCondition.count, json_response.size
  end

  test "should create condition" do
    rule = categorization_rules(:one)
    assert_difference('CategorizationCondition.count') do
      post categorization_conditions_url, params: {
        categorizationRuleId: rule.id,
        transactionField: 'description',
        matchType: 'exactly',
        matchValue: 'Coffee'
      }
    end
    assert_response :created
    json_response = JSON.parse(response.body)

    assert_equal json_response['categorizationRuleId'], rule.id
    assert_equal json_response['transactionField'], 'description'
    assert_equal json_response['matchType'], 'exactly'
    assert_equal json_response['matchValue'], 'Coffee'
  end

  test "should render create errors with invalid params" do
    rule = categorization_rules(:one)
    assert_no_difference('CategorizationCondition.count') do
      post categorization_conditions_url, params: {
        categorizationRuleId: rule.id,
        transactionField: 'description',
        matchType: 'exactly',
      }
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    expected_error = {
      "field" => "matchValue",
      "message" =>  "matchValue can't be blank"
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should update condition" do
    condition = categorization_conditions(:description_exactly)

    patch categorization_condition_url(condition), params: {
      transactionField: 'amount',
      matchType: 'exactly',
      matchValue: '1.23'
    }
    assert_response :success

    condition.reload
    assert_equal condition.transaction_field, 'amount'
    assert_equal condition.match_type, 'exactly'
    assert_equal condition.match_value, '1.23'
  end

  test "should render update errors with invalid params" do
    condition = categorization_conditions(:description_exactly)

    patch categorization_condition_url(condition), params: {
      transactionField: 'amount',
      matchType: '', # Invalid matchType (blank)
      matchValue: '1.23'
    }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    expected_error = {
      "field" => "matchType",
      "message" =>  "matchType is not valid for the field 'amount` Valid match types are: greater_than, less_than, exactly"
    }

    assert_includes json_response['errors'], expected_error
  end

  test "should destroy condition" do
    condition = categorization_conditions(:description_exactly)

    assert_difference('CategorizationCondition.count', -1) do
      delete categorization_condition_url(condition)
    end

    assert_response :no_content
  end
end
