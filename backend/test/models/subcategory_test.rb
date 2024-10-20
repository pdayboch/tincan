# frozen_string_literal: true

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
require 'test_helper'

class SubcategoryTest < ActiveSupport::TestCase
  test 'should not save duplicate subcategory names' do
    category = categories(:one)
    Subcategory.create(name: 'UniqueName', category_id: category.id)
    duplicate_subcategory = Subcategory.new(name: 'UniqueName', category_id: category.id)

    assert_not duplicate_subcategory.valid?, 'Duplicate category should not be valid'
    assert_includes duplicate_subcategory.errors[:name], 'already exists'
  end

  test 'should not delete subcategory with transactions' do
    subcategory = subcategories(:one)
    assert_not subcategory.transactions.empty?, 'Subcategory should have transactions for this test'

    assert_raises ActiveRecord::DeleteRestrictionError do
      subcategory.destroy
    end

    assert Subcategory.exists?(subcategory.id), 'Subcategory should still exist after attempting to delete'
  end
end
