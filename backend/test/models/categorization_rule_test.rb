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
require "test_helper"

class CategorizationRuleTest < ActiveSupport::TestCase
  test "create syncs the category with the subcategory" do
    subcategory = subcategories(:one)
    category = subcategory.category

    rule = CategorizationRule.create(subcategory_id: subcategory.id)

    assert_equal rule.category_id, category.id
  end

  test "update syncs the category with the subcategory" do
    old_subcategory = subcategories(:one)
    new_subcategory = subcategories(:two)
    new_category = new_subcategory.category
    rule = CategorizationRule.create(subcategory_id: old_subcategory.id)

    rule.update(subcategory_id: new_subcategory.id)

    assert_equal rule.subcategory_id, new_subcategory.id
    assert_equal rule.category_id, new_category.id
  end
end
