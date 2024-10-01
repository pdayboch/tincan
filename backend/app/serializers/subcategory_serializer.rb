# frozen_string_literal: true

class SubcategorySerializer < ActiveModel::Serializer
  attributes :id, :name

  attribute :categoryId do
    object.category_id
  end
end
