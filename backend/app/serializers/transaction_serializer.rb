class TransactionSerializer < ActiveModel::Serializer
  attributes :id,
    :transaction_date,
    :amount,
    :description,
    :account_id,
    :statement_id

  attribute :category_name do
    object.category&.name
  end

  attribute :subcategory_name do
    object.subcategory&.name
  end
end
