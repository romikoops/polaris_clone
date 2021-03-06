# frozen_string_literal: true

FactoryBot.define do
  factory :stop do
    association :hub
    association :itinerary
    sequence(:index) { |n| n }
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
