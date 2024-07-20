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
