# frozen_string_literal: true

FactoryBot.define do
  factory :hub do
    trait :with_lat_lng do
      latitude { '57.694253' }
      longitude { '11.854048' }
    end

    name { 'Gothenburg Port' }
    hub_type { 'ocean' }
    hub_status { 'active' }
    hub_code { 'GOO1' }
    association :tenant
    association :address
    association :nexus
    association :mandatory_charge
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint(8)        not null, primary key
#  tenant_id           :integer
#  address_id          :integer
#  name                :string
#  hub_type            :string
#  latitude            :float
#  longitude           :float
#  hub_status          :string           default("active")
#  hub_code            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  trucking_type       :string
#  photo               :string
#  nexus_id            :integer
#  mandatory_charge_id :integer
#
