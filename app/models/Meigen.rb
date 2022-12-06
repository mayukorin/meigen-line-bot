require 'net/http'

class Meigen < ApplicationRecord

    belongs_to :gacha
    belongs_to :author
    
end