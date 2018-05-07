class Courier < ApplicationRecord
  has_many :trucking_pricings
  belongs_to :tenant
end
