class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.date :transaction_date
      t.decimal :amount, precision: 10, scale: 2
      t.text :description
      t.references :account, null: false, foreign_key: true
      t.references :statement, null: true, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :subcategory, null: false, foreign_key: true

      t.timestamps
    end
  end
end
