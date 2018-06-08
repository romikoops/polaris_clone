# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :itinerary, optional: true
  belongs_to :hub, optional: true
  belongs_to :trucking_pricing, optional: true
end
