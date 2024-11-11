class CreateCategorizationConditions < ActiveRecord::Migration[7.2]
  def change
    create_table :categorization_conditions do |t|
      t.references :categorization_rule, null: false, foreign_key: true
      t.string :transaction_field, null: false
      t.string :match_type, null: false
      t.string :match_value, null: false

      t.timestamps
    end
  end
end
