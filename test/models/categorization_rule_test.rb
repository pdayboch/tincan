# frozen_string_literal: true

# == Schema Information
#
# Table name: categorization_rules
#
#  id             :bigint           not null, primary key
#  category_id    :bigint           not null
#  subcategory_id :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require 'test_helper'

class CategorizationRuleTest < ActiveSupport::TestCase
  test 'create syncs the category with the subcategory' do
    subcategory = subcategories(:paycheck)
    category = subcategory.category

    rule = CategorizationRule.create(subcategory_id: subcategory.id)

    assert_equal rule.category_id, category.id
  end

  test 'update syncs the category with the subcategory' do
    old_subcategory = subcategories(:paycheck)
    new_subcategory = subcategories(:restaurant)
    new_category = new_subcategory.category
    rule = CategorizationRule.create(subcategory_id: old_subcategory.id)

    rule.update(subcategory_id: new_subcategory.id)

    assert_equal rule.subcategory_id, new_subcategory.id
    assert_equal rule.category_id, new_category.id
  end

  test 'match? returns false when no conditions are present' do
    categorization_rule = CategorizationRule.new
    categorization_rule.stub :categorization_conditions, [] do
      assert_not categorization_rule.match?(Object.new)
    end
  end

  test 'match? returns false when one condition does not match' do
    categorization_rule = CategorizationRule.new
    condition1 = Minitest::Mock.new
    condition2 = Minitest::Mock.new

    condition1.expect :matches?, true, [Object]
    condition2.expect :matches?, false, [Object]

    categorization_rule.stub :categorization_conditions, [condition1, condition2] do
      assert_not categorization_rule.match?(Object.new)
    end

    condition1.verify
    condition2.verify
  end

  test 'match? returns true when all conditions match' do
    categorization_rule = CategorizationRule.new
    condition1 = Minitest::Mock.new
    condition2 = Minitest::Mock.new

    condition1.expect :matches?, true, [Object]
    condition2.expect :matches?, true, [Object]

    categorization_rule.stub :categorization_conditions, [condition1, condition2] do
      assert categorization_rule.match?(Object.new)
    end

    condition1.verify
    condition2.verify
  end
end
