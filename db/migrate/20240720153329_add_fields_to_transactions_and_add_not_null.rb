class AddFieldsToTransactionsAndAddNotNull < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :notes, :text
    add_column :transactions, :statement_description, :text
    add_column :transactions, :statement_transaction_date, :date

    change_column_null :transactions, :transaction_date, false
    change_column_null :transactions, :amount, false
  end
end
