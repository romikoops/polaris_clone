# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_transit_time, class: "Legacy::TransitTime" do
    association :itinerary, factory: :legacy_itinerary
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
    duration { 20 }
  end
end

# == Schema Information
#
# Table name: legacy_transit_times
#
#  id                :uuid             not null, primary key
#  duration          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  itinerary_id      :integer
#  tenant_vehicle_id :integer
#
# Indexes
#
#  index_legacy_transit_times_on_itinerary_id       (itinerary_id)
#  index_legacy_transit_times_on_tenant_vehicle_id  (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (itinerary_id => itineraries.id)
#  fk_rails_...  (tenant_vehicle_id => tenant_vehicles.id)
#
