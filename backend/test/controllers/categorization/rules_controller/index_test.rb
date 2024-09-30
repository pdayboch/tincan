# frozen_string_literal: true

require 'test_helper'

module Categorization
  class RulesControllerIndexTest < ActionDispatch::IntegrationTest
    test 'should get index from CategorizationRuleDataEntity' do
      # Capture the original CategorizationRuleDataEntity.new method
      original_new = CategorizationRuleDataEntity.method(:new)

      # Expect .new to be called and call the original constructor
      CategorizationRuleDataEntity
        .expects(:new)
        .returns(original_new.call)

      get categorization_rules_url

      assert_response :success

      json_response = response.parsed_body
      assert_equal CategorizationRule.count, json_response.size
    end
  end
end
