class AddParserClassToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :parser_class, :string
  end
end
