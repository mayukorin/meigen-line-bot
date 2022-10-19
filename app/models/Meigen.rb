class Meigen < ApplicationRecord

    belongs_to :category, dependent: :destroy
    belongs_to :author, dependent: :destroy
  
end