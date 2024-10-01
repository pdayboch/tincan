# frozen_string_literal: true

class CategoryDataEntity
  def data
    @categories = Category.all
    {
      total_items: 10,
      filtered_items: 5,
      categories: @categories.map { |c| single_category_data(c) }
    }
  end

  def single_category_data(category)
    {
      id: category.id,
      name: category.name,
      has_transactions: category_has_transactions_associated?(category),
      subcategories: subcategory_data(category)
    }
  end

  def subcategory_data(category)
    category.subcategories.map do |subcategory|
      {
        id: subcategory.id,
        name: subcategory.name,
        has_transactions: subcategory_has_transactions_associated?(subcategory)
      }
    end
  end

  def category_has_transactions_associated?(category)
    category.transactions.any?
  end

  def subcategory_has_transactions_associated?(subcategory)
    subcategory.transactions.any?
  end
end
