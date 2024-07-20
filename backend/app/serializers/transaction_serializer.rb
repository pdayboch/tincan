# == Schema Information
#
# Table name: transactions
#
#  id                         :bigint           not null, primary key
#  transaction_date           :date             not null
#  amount                     :decimal(10, 2)   not null
#  description                :text
#  account_id                 :bigint           not null
#  statement_id               :bigint
#  category_id                :bigint           not null
#  subcategory_id             :bigint           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  notes                      :text
#  statement_description      :text
#  statement_transaction_date :date
#
class TransactionSerializer < ActiveModel::Serializer
  attributes :id,
    :amount,
    :description

  attribute :transaction_date do
    object.transaction_date.strftime('%m/%d/%Y')
  end

  attribute :account do
    {
      id: object.account.id,
      bank: object.account.bank_name,
      name: object.account.name
    }
  end

  attribute :user do
    {
      id: object.account.user.id,
      name: object.account.user.name
    }
  end

  attribute :category do
    {
      id: object.category.id,
      name: object.category.name
    }
  end

  attribute :subcategory do
    {
      id: object.subcategory.id,
      name: object.subcategory.name
    }
  end
end
