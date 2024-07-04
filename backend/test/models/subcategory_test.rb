# == Schema Information
#
# Table name: subcategories
#
#  id          :bigint           not null, primary key
#  name        :string
#  category_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class SubcategoryTest < ActiveSupport::TestCase
  test 'should not save duplicate subcategory names' do
    Category.create(name: 'UniqueName')
    duplicate_category = Category.new(name: 'UniqueName')

    assert_not duplicate_category.valid?, 'Duplicate category should not be valid'
    assert_includes duplicate_category.errors[:name], 'already exists'
  end

  test 'should not delete subcategory with transactions' do
    subcategory = subcategories(:one)
    assert_not subcategory.transactions.empty?, 'Subcategory should have transactions for this test'

    assert_no_difference 'Subcategory.count' do
      assert_not subcategory.destroy, 'Subcategory was destroyed despite having associated transactions'
    end
  end
end
