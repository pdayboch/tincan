class CategorizationRuleSerializer < ActiveModel::Serializer
  attributes :id

  attribute :categoryId do
    object.category_id
  end

  attribute :subcategoryId do
    object.subcategory_id
  end
end
