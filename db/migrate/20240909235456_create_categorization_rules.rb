class CreateCategorizationRules < ActiveRecord::Migration[7.2]
  def change
    create_table :categorization_rules do |t|
      t.references :category, null: false, foreign_key: true
      t.references :subcategory, null: false, foreign_key: true

      t.timestamps
    end
  end
end
