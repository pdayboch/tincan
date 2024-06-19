class CategoryData
  def initialize(categories)
    @categories = categories
  end

  def get_data
    @categories.map { |c| single_category_data(c) }
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
    []
  end

  def category_has_transactions_associated?(category)
    false
  end

  def subcategory_has_transactions_associated?(subcategory)
    false
  end
end
