# frozen_string_literal: true

# == Schema Information
#
# Table name: subcategories
#
#  id          :bigint           not null, primary key
#  name        :string
#  category_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class SubcategorySerializer < ActiveModel::Serializer
  attributes :id, :name

  attribute :categoryId do
    object.category_id
  end

  attribute :hasTransactions do
    object.transactions.any?
  end
end
