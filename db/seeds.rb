# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'csv'

ActiveRecord::Base.transaction do 
  cnt = 0
  Meigen.destroy_all
  CSV.foreach('db/meigen.csv') do |row|
    if cnt == 0
      row[0] = (row[0])[1..-1]
    end
    meigen = Meigen.new(
      body: row[0],
    )
    Gacha.find_or_create_by(name: row[1]).meigens << meigen
    Author.find_or_create_by(name: row[2]).meigens << meigen
    cnt += 1
  end
end

ActiveRecord::Base.transaction do 
  Gacha.find_or_create_by(name: "オリジナルの名言")
end