# frozen_string_literal: true

require 'test_helper'

module Categorization
  class RulesControllerDestroyTest < ActionDispatch::IntegrationTest
    test 'should destroy rule' do
      rule = categorization_rules(:one)
      conditions_count = rule.categorization_conditions.count

      assert_difference('CategorizationCondition.count', -conditions_count) do
        delete categorization_rule_url(rule)
      end

      assert_response :no_content
    end
  end
end
