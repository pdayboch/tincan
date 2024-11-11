# frozen_string_literal: true

# == Schema Information
#
# Table name: categorization_rules
#
#  id             :bigint           not null, primary key
#  category_id    :bigint           not null
#  subcategory_id :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
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
