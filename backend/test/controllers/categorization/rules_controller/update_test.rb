# frozen_string_literal: true

require 'test_helper'

module Categorization
  class RulesControllerUpdateTest < ActionDispatch::IntegrationTest
    test 'should update rule with valid conditions' do
      rule = categorization_rules(:one)
      conditions = [{
        transactionField: 'description',
        matchType: 'starts_with',
        matchValue: 'updated value'
      }]

      new_subcategory = subcategories(:unused_subcategory)

      patch categorization_rule_url(rule), params: {
        subcategoryId: new_subcategory.id,
        conditions: conditions
      }
      assert_response :success

      rule.reload
      assert_equal rule.subcategory_id, new_subcategory.id
      assert rule.categorization_conditions.size, 1
      assert_equal rule.categorization_conditions.first.transaction_field, 'description'
      assert_equal rule.categorization_conditions.first.match_type, 'starts_with'
      assert_equal rule.categorization_conditions.first.match_value, 'updated value'
    end

    test 'should not change conditions if omitted' do
      rule = categorization_rules(:one)
      original_conditions_count = rule.categorization_conditions.count

      new_subcategory = subcategories(:unused_subcategory)

      patch categorization_rule_url(rule), params: {
        subcategoryId: new_subcategory.id
      }
      assert_response :success

      rule.reload
      assert_equal rule.subcategory_id, new_subcategory.id
      assert rule.categorization_conditions.size, original_conditions_count
    end

    test 'should not change omitted attributes with conditions' do
      rule = categorization_rules(:one)
      original_subcategory = rule.subcategory

      conditions = [{
        transactionField: 'description',
        matchType: 'starts_with',
        matchValue: 'updated value'
      }]

      patch categorization_rule_url(rule), params: {
        conditions: conditions
      }
      assert_response :success

      rule.reload
      assert_equal rule.subcategory_id, original_subcategory.id
      assert rule.categorization_conditions.size, 1
      assert_equal rule.categorization_conditions.first.transaction_field, 'description'
      assert_equal rule.categorization_conditions.first.match_type, 'starts_with'
      assert_equal rule.categorization_conditions.first.match_value, 'updated value'
    end

    test 'should clear conditions when passed empty array' do
      rule = categorization_rules(:one)
      assert rule.categorization_conditions.any?

      patch categorization_rule_url(rule), params: {
        conditions: []
      }
      assert_response :success

      rule.reload
      assert rule.categorization_conditions.empty?
    end

    test 'should render update errors when rule model is invalid' do
      rule = categorization_rules(:one)
      patch categorization_rule_url(rule), params: { subcategoryId: 0 }

      assert_response :unprocessable_entity

      json_response = response.parsed_body
      expected_error = {
        'field' => 'subcategory',
        'message' => 'subcategory must exist'
      }

      assert_equal json_response['errors'], [expected_error]
    end

    test 'should render update errors when categoryId is included' do
      rule = categorization_rules(:one)

      patch categorization_rule_url(rule), params: {
        categoryId: 1
      }
      assert_response :unprocessable_entity
      json_response = response.parsed_body
      message = 'categoryId parameter is not accepted. Please set the subcategoryId, ' \
                'and the category will be inferred automatically.'
      expected_error = {
        'field' => 'categoryId',
        'message' => message
      }

      assert_includes json_response['errors'], expected_error
    end

    test 'should render update errors for invalid condition values' do
      rule = categorization_rules(:one)
      conditions = [{
        something: 'bad_field',
        matchType: 'starts_with',
        matchValue: 'updated value'
      }]

      patch categorization_rule_url(rule), params: {
        conditions: conditions
      }
      assert_response :unprocessable_entity
      json_response = response.parsed_body

      expected_error = {
        'field' => 'transactionField',
        'message' => "transactionField can't be blank"
      }

      assert_includes json_response['errors'], expected_error
    end
  end
end
