# frozen_string_literal: true

class HubTrucking < ApplicationRecord
  belongs_to :trucking_pricing
  belongs_to :hub
  belongs_to :trucking_destination
  validates :trucking_pricing_id, :hub_id, :trucking_destination_id, presence: true
end

# == Schema Information
#
# Table name: hub_truckings
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  hub_id                  :integer
#  trucking_destination_id :integer
#  trucking_pricing_id     :integer
#
# Indexes
#
#  foreign_keys                   (trucking_pricing_id,trucking_destination_id,hub_id) UNIQUE
#  index_hub_truckings_on_hub_id  (hub_id)
#
