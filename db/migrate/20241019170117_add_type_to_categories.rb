# frozen_string_literal: true

class AddTypeToCategories < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL.squish
      CREATE TYPE category_type AS ENUM ('income', 'spend', 'transfer');
    SQL
    add_column :categories, :category_type, :category_type
    add_index :categories, :category_type
  end

  def down
    remove_index :categories, :category_type
    remove_column :categories, :category_type
    execute <<-SQL.squish
      DROP TYPE category_type;
    SQL
  end
end
