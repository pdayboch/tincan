# frozen_string_literal: true

require 'test_helper'

module Categorization
  class RulesControllerCreateTest < ActionDispatch::IntegrationTest
    test 'should create rule without conditions' do
      subcategory = subcategories(:paycheck)
      category = subcategory.category

      assert_difference('CategorizationRule.count') do
        post categorization_rules_url, params: {
          subcategoryId: subcategory.id
        }
      end
      assert_response :created
      json_response = response.parsed_body

      assert_equal json_response['subcategory']['id'], subcategory.id
      assert_equal json_response['category']['id'], category.id
      assert_equal json_response['conditions'], []
    end

    test 'should create rule with conditions' do
      subcategory = subcategories(:paycheck)

      condition_params = [{
        transactionField: 'description',
        matchType: 'starts_with',
        matchValue: 'coffee shop'
      }]

      assert_difference(['CategorizationRule.count', 'CategorizationCondition.count']) do
        post categorization_rules_url, params: {
          subcategoryId: subcategory.id,
          conditions: condition_params
        }
      end
      assert_response :created
      json_response = response.parsed_body

      assert_equal json_response['subcategory']['id'], subcategory.id
      assert_equal json_response['conditions'].size, 1
      assert_equal json_response['conditions'][0]['transactionField'], 'description'
      assert_equal json_response['conditions'][0]['matchType'], 'starts_with'
      assert_equal json_response['conditions'][0]['matchValue'], 'coffee shop'
    end

    test 'should create rule with empty conditions' do
      subcategory = subcategories(:paycheck)

      assert_difference(['CategorizationRule.count']) do
        post categorization_rules_url, params: {
          subcategoryId: subcategory.id,
          conditions: []
        }
      end
      assert_response :created
      json_response = response.parsed_body

      assert_equal json_response['subcategory']['id'], subcategory.id
      assert_equal json_response['conditions'].size, 0
    end

    test 'should render create errors when rule model is invalid' do
      assert_no_difference('CategorizationRule.count') do
        post categorization_rules_url, params: {}
      end
      assert_response :unprocessable_entity
      json_response = response.parsed_body
      expected_error = [
        {
          'field' => 'category',
          'message' => 'category must exist'
        },
        {
          'field' => 'subcategory',
          'message' => 'subcategory must exist'
        }
      ]

      assert_equal json_response['errors'], expected_error
    end

    test 'should render create errors when categoryId is included' do
      assert_no_difference('CategorizationCondition.count') do
        post categorization_rules_url, params: {
          categoryId: 1,
          subcategoryId: 2
        }
      end
      assert_response :unprocessable_entity

      json_response = response.parsed_body
      message = 'categoryId parameter is not accepted. Please set the subcategoryId, ' \
                'and the category will be inferred automatically.'
      expected_error = [{
        'field' => 'categoryId',
        'message' => message
      }]

      assert_equal json_response['errors'], expected_error
    end

    test 'should render create errors for invalid condition keys' do
      subcategory = subcategories(:paycheck)
      invalid_conditions = [{
        something: 'description',
        matchType: 'exactly',
        matchValue: 'anything'
      }]

      assert_no_difference('CategorizationRule.count') do
        post categorization_rules_url, params: {
          subcategoryId: subcategory.id,
          conditions: invalid_conditions
        }
      end
      assert_response :unprocessable_entity
      json_response = response.parsed_body
      expected_error = [{
        'field' => 'transactionField',
        'message' => "transactionField can't be blank"
      }]

      assert_equal json_response['errors'], expected_error
    end

    test 'should render create errors for invalid condition values' do
      subcategory = subcategories(:paycheck)
      invalid_conditions = [{
        transactionField: 'bad_field',
        matchType: 'exactly',
        matchValue: 'anything'
      }]

      assert_no_difference('CategorizationRule.count') do
        post categorization_rules_url, params: {
          subcategoryId: subcategory.id,
          conditions: invalid_conditions
        }
      end
      assert_response :unprocessable_entity
      json_response = response.parsed_body
      valid_fields = CategorizationCondition::MATCH_TYPES_FOR_FIELDS.keys.join(', ')
      expected_error = [{
        'field' => 'transactionField',
        'message' => "transactionField bad_field is invalid. The options are: #{valid_fields}"
      }]

      assert_equal json_response['errors'], expected_error
    end
  end
end
