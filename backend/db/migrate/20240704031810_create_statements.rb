class CreateStatements < ActiveRecord::Migration[7.1]
  def change
    create_table :statements do |t|
      t.date :statement_date
      t.references :account, null: false, foreign_key: true
      t.float :statement_balance

      t.timestamps
    end
  end
end
