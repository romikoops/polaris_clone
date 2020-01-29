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
      unless evaluator.pricing_detail_attrs.empty?
        pricing_detail_options = { priceable: pricing, tenant: pricing.tenant }
        pricing_detail_options.merge!(evaluator.pricing_detail_attrs)
        create_list :pricing_detail, 1, **pricing_detail_options
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings
#
#  id                    :bigint           not null, primary key
#  effective_date        :datetime
#  expiration_date       :datetime
#  internal              :boolean          default(FALSE)
#  uuid                  :uuid
#  wm_rate               :decimal(, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  itinerary_id          :bigint
#  sandbox_id            :uuid
#  tenant_id             :bigint
#  tenant_vehicle_id     :integer
#  transport_category_id :bigint
#  user_id               :bigint
#
# Indexes
#
#  index_pricings_on_itinerary_id           (itinerary_id)
#  index_pricings_on_sandbox_id             (sandbox_id)
#  index_pricings_on_tenant_id              (tenant_id)
#  index_pricings_on_transport_category_id  (transport_category_id)
#  index_pricings_on_user_id                (user_id)
#  index_pricings_on_uuid                   (uuid) UNIQUE
#
