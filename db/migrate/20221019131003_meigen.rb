class Meigen < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :name

      t.timestamps
    end
    
    create_table :meigens do |t|
      t.text :body
      t.references :category, foreign_key: true
      t.references :author, foreign_key: true

      t.timestamps
    end
  end
end
