require "test_helper"

class SubcategoryTest < ActiveSupport::TestCase
  test 'should not save duplicate subcategory names' do
    Category.create(name: 'UniqueName')
    duplicate_category = Category.new(name: 'UniqueName')

    assert_not duplicate_category.valid?, 'Duplicate category should not be valid'
    assert_includes duplicate_category.errors[:name], 'already exists'
  end
end
