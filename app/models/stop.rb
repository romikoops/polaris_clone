class Stop < ApplicationRecord
  belongs_to :itinerary
  belongs_to :hub
  has_many :layovers
end
