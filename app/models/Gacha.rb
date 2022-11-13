class Gacha < ApplicationRecord
    has_many :meigens, dependent: :destroy
end
  