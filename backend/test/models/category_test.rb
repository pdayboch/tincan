# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test 'should not save duplicate category names' do
    Category.create(name: 'UniqueName')
    duplicate_category = Category.new(name: 'UniqueName')

    assert_not duplicate_category.valid?, 'Duplicate category should not be valid'
    assert_includes duplicate_category.errors[:name], 'already exists'
  end
end
