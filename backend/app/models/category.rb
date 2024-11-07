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
class Category < ApplicationRecord
  enum :category_type,
       {
         income: 'income',
         spend: 'spend',
         transfer: 'transfer'
       }

  has_many :transactions, dependent: :restrict_with_exception
  has_many :subcategories, dependent: :destroy

  validates :name, uniqueness: { message: 'already exists' }
  validates :category_type, presence: true
end
