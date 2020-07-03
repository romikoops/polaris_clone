# frozen_string_literal: true

FactoryBot.define do
  factory :trip do
    start_date { Time.zone.today + 7.days }
    end_date { Time.zone.tomorrow + 20.days }
    closing_date { Time.zone.today + 2.days }
    association :itinerary
    association :tenant_vehicle, factory: :tenant_vehicle
  end
end

# == Schema Information
#
# Table name: trips
#
#  id                :bigint           not null, primary key
#  closing_date      :datetime
#  end_date          :datetime
#  load_type         :string
#  start_date        :datetime
#  vessel            :string
#  voyage_code       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  itinerary_id      :integer
#  sandbox_id        :uuid
#  tenant_vehicle_id :integer
#
# Indexes
#
#  index_trips_on_closing_date       (closing_date)
#  index_trips_on_itinerary_id       (itinerary_id)
#  index_trips_on_sandbox_id         (sandbox_id)
#  index_trips_on_tenant_vehicle_id  (tenant_vehicle_id)
#
