class Layover < ApplicationRecord
  belongs_to :stop
  belongs_to :itinerary
end
