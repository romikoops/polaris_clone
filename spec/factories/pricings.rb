# frozen_string_literal: true

FactoryBot.define do
  factory :pricing do
    wm_rate { 'Gothenburg' }
    effective_date { Date.today }
    expiration_date { 10.days.from_now }
    association :transport_category
    association :tenant
    association :itinerary
    association :tenant_vehicle

    after :create do |pricing|
      create_list :pricing_detail, 1, priceable: pricing, tenant: pricing.tenant
    end
  end
end

# == Schema Information
#
# Table name: pricings
#
#  id                    :bigint(8)        not null, primary key
#  wm_rate               :decimal(, )
#  effective_date        :datetime
#  expiration_date       :datetime
#  tenant_id             :bigint(8)
#  transport_category_id :bigint(8)
#  user_id               :bigint(8)
#  itinerary_id          :bigint(8)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tenant_vehicle_id     :integer
#  uuid                  :uuid
#
