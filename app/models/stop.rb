# frozen_string_literal: true

class Stop < Legacy::Stop
  belongs_to :itinerary, dependent: :destroy
  belongs_to :hub
  has_many :layovers, dependent: :destroy

  validates :index, uniqueness: {scope: %i[itinerary_id hub_id]}
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
