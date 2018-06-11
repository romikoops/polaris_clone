# frozen_string_literal: true

class HubTrucking < ApplicationRecord
  belongs_to :trucking_pricing
  belongs_to :hub
  belongs_to :trucking_destination
  validates :trucking_pricing_id, :hub_id, :trucking_destination_id, presence: true
end
