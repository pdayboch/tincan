# frozen_string_literal: true

class CategoryDataEntity
  def data
    categories = base_query
    {
      totalItems: categories.count,
      filteredItems: categories.count, # TODO: add filter support
      categories: categories.map { |c| single_category_data(c) }
    }
  end

  private

  def base_query
    Category.includes(:subcategories)
  end

  def single_category_data(category)
    {
      id: category.id,
      name: category.name,
      hasTransactions: category_has_transactions_associated?(category),
      subcategories: subcategory_data(category)
    }
  end

  def subcategory_data(category)
    category.subcategories.map do |subcategory|
      SubcategorySerializer.new(subcategory).as_json
    end
  end

  def category_has_transactions_associated?(category)
    category.transactions.any?
  end
end
