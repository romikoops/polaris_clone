# frozen_string_literal: true

module Legacy
  class TransitTime < ApplicationRecord
    belongs_to :itinerary, class_name: 'Legacy::Itinerary'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle'

    validates :itinerary_id, uniqueness: { scope: :tenant_vehicle }
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
