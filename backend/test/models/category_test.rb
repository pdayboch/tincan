# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'should not save duplicate category names' do
    Category.create(name: 'UniqueName')
    duplicate_category = Category.new(name: 'UniqueName')

    assert_not duplicate_category.valid?, 'Duplicate category should not be valid'
    assert_includes duplicate_category.errors[:name], 'already exists'
  end

  test 'should not delete category with transactions' do
    category = categories(:one)
    assert_not category.transactions.empty?, 'Category should have transactions for this test'

    assert_raises ActiveRecord::DeleteRestrictionError do
      category.destroy
    end

    assert Category.exists?(category.id), 'Category should still exist after attempting to delete'
  end
end
