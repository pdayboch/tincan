# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id            :bigint           not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_type :enum
#
class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name

  attribute :categoryType do
    object.category_type
  end

  attribute :hasTransactions do
    object.transactions.any?
  end
end
