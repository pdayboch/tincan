# frozen_string_literal: true

require 'test_helper'

class CategoryDataEntityTest < ActiveSupport::TestCase
  test 'returns all categories' do
    result = CategoryDataEntity.new.data

    assert result[:totalItems].present?
    assert result[:filteredItems].present?
    assert result[:categories].present?
    assert_equal result[:totalItems], Category.count
    assert_equal result[:categories].count, Category.count
    assert result[:categories][0][:id].present?
    assert result[:categories][0][:name].present?
    assert result[:categories][0][:hasTransactions].present?
    assert result[:categories][0][:subcategories].present?
  end
end
