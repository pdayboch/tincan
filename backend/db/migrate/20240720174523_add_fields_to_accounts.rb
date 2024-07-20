class AddFieldsToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :statement_directory, :text
  end
end
