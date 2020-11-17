# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe TransitTime, type: :model do
    it 'creates a valid transit time' do
      expect(FactoryBot.build(:legacy_transit_time)).to be_valid
    end
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
