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

    transient do
      pricing_detail_attrs { {} }
    end

    after :create do |pricing, evaluator|
      pricing_detail_options = { priceable: pricing, tenant: pricing.tenant }
      pricing_detail_options.merge!(evaluator.pricing_detail_attrs)
      create_list :pricing_detail, 1, **pricing_detail_options
    end
  end
end

# == Schema Information
#
# Table name: pricings
#
#  id                    :bigint           not null, primary key
#  wm_rate               :decimal(, )
#  effective_date        :datetime
#  expiration_date       :datetime
#  tenant_id             :bigint
#  transport_category_id :bigint
#  user_id               :bigint
#  itinerary_id          :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tenant_vehicle_id     :integer
#  uuid                  :uuid
#  sandbox_id            :uuid
#  internal              :boolean          default(FALSE)
#
