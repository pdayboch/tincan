class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :bank_name
      t.string :name, null: false
      t.string :account_type
      t.boolean :active, default: true
      t.boolean :deletable, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
