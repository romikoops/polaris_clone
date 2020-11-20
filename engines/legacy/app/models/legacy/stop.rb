# frozen_string_literal: true

module Legacy
  class Stop < ApplicationRecord
    self.table_name = "stops"

    default_scope { order("index asc") }

    belongs_to :itinerary
    belongs_to :hub
    has_many :layovers, dependent: :destroy
  end
end

# == Schema Information
#
# Table name: stops
#
#  id           :bigint           not null, primary key
#  index        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  hub_id       :integer
#  itinerary_id :integer
#  sandbox_id   :uuid
#
# Indexes
#
#  index_stops_on_hub_id        (hub_id)
#  index_stops_on_itinerary_id  (itinerary_id)
#  index_stops_on_sandbox_id    (sandbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (itinerary_id => itineraries.id)
#
