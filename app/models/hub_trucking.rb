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
#  id                      :bigint(8)        not null, primary key
#  hub_id                  :integer
#  trucking_destination_id :integer
#  trucking_pricing_id     :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
