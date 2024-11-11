class AddFieldsToStatements < ActiveRecord::Migration[7.1]
  def change
    add_column :statements, :pdf_file_path, :text
  end
end
