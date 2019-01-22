# frozen_string_literal: true

FactoryBot.define do
  factory :trip do
    start_date { Date.today }
    end_date { Date.tomorrow }
    association :itinerary
    association :tenant_vehicle
  end
end

# == Schema Information
#
# Table name: trips
#
#  id                :bigint(8)        not null, primary key
#  itinerary_id      :integer
#  start_date        :datetime
#  end_date          :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  voyage_code       :string
#  vessel            :string
#  tenant_vehicle_id :integer
#  closing_date      :datetime
#  load_type         :string
#
