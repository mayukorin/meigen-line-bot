class RenameCategoryColumnToCategories < ActiveRecord::Migration[7.0]
  def change
    rename_column :categories, :Category, :name
  end
end
