class ChangeCategoriesToGachas < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :meigens, :categories
    remove_reference :meigens, :category, inde: true
    rename_table :categories, :gachas
    add_reference :meigens, :gacha
  end
end
