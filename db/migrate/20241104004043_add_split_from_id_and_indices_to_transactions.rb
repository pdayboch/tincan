# frozen_string_literal: true

class AddSplitFromIdAndIndicesToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions,
               :split_from_id,
               :bigint,
               comment: 'References the parent transaction if this transaction is a split'

    add_column :transactions,
               :has_splits,
               :boolean,
               null: false,
               default: false,
               comment: 'Indicates if this transaction has associated split transactions'

    add_foreign_key :transactions,
                    :transactions,
                    column: :split_from_id,
                    on_delete: :nullify

    # Add partial index for optimized lookups of transactions that are splits
    add_index :transactions,
              :split_from_id,
              where: 'split_from_id IS NOT NULL',
              name: 'index_transactions_on_split_from_id_not_null'

    # Add composite index for cursor-based pagination on transaction_date and id
    add_index :transactions,
              %i[transaction_date id],
              name: 'index_transactions_on_transaction_date_and_id'
  end
end
