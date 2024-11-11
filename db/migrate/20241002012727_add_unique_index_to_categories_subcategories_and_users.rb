class AddUniqueIndexToCategoriesSubcategoriesAndUsers < ActiveRecord::Migration[7.2]
  def change
    # Add unique index to the name column of the categories table
    add_index :categories, :name, unique: true

    # Add unique index to the name column of the subcategories table
    add_index :subcategories, :name, unique: true

    # Add unique index to the email column of the users table
    add_index :users, :email, unique: true
  end
end
