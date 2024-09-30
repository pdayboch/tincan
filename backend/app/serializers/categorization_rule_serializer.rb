# frozen_string_literal: true

class CategorizationRuleSerializer < ActiveModel::Serializer
  attributes :id

  attribute :category do
    {
      id: object.category_id,
      name: object.category.name
    }
  end

  attribute :subcategory do
    {
      id: object.subcategory_id,
      name: object.subcategory.name
    }
  end

  attribute :conditions do
    object.categorization_conditions.map do |condition|
      CategorizationConditionSerializer.new(condition).as_json
    end
  end
end
