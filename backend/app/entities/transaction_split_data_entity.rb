# frozen_string_literal: true

class TransactionSplitDataEntity
  def initialize(original_transaction)
    @original_transaction = original_transaction
  end

  def data
    {
      original: TransactionSerializer.new(@original_transaction).as_json,
      splits: serialized_splits
    }
  end

  private

  def splits_query
    @original_transaction.splits
                         .includes(:subcategory, :category, :account, account: :user)
  end

  def serialized_splits
    splits_query.map { |split| TransactionSerializer.new(split).as_json }
  end
end
