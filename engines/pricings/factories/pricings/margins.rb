# frozen_string_literal: true

FactoryBot.define do
  factory :pricings_margin, class: "Pricings::Margin" do
    value { 0.10 }
    operator { "%" }
    margin_type { :freight_margin }
    effective_date { Time.zone.today.beginning_of_day }
    expiration_date { 6.months.from_now.end_of_day }
    association :organization, factory: :organizations_organization
    association :applicable, factory: :users_client

    trait :freight do
      margin_type { :freight_margin }
    end

    trait :export do
      margin_type { :export_margin }
    end

    trait :import do
      margin_type { :import_margin }
    end

    trait :trucking_pre do
      margin_type { :trucking_pre_margin }
    end

    trait :trucking_on do
      margin_type { :trucking_on_margin }
    end

    trait :user do
      association :applicable, factory: :users_client
    end

    trait :group do
      association :applicable, factory: :users_group
    end

    trait :addition do
      value { 10 }
      operator { "+" }
    end

    trait :organization do
      association :applicable, factory: :organizations_organization
    end

    factory :user_margin, traits: [:user]
    factory :group_margin, traits: [:group]
    factory :organization_margin, traits: [:organization]
    factory :addition_margin, traits: [:addition]
    factory :freight_margin, traits: [:freight]
    factory :import_margin, traits: [:import]
    factory :export_margin, traits: [:export]
    factory :trucking_pre_margin, traits: [:trucking_pre]
    factory :trucking_on_margin, traits: [:trucking_on]
  end
end

# == Schema Information
#
# Table name: pricings_margins
#
#  id                 :uuid             not null, primary key
#  applicable_type    :string
#  application_order  :integer          default(0)
#  cargo_class        :string
#  default_for        :string
#  effective_date     :datetime
#  expiration_date    :datetime
#  margin_type        :integer
#  operator           :string
#  validity           :daterange
#  value              :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  applicable_id      :uuid
#  destination_hub_id :integer
#  itinerary_id       :integer
#  organization_id    :uuid
#  origin_hub_id      :integer
#  pricing_id         :uuid
#  sandbox_id         :uuid
#  tenant_id          :uuid
#  tenant_vehicle_id  :integer
#
# Indexes
#
#  index_pricings_margins_on_applicable_type_and_applicable_id  (applicable_type,applicable_id)
#  index_pricings_margins_on_application_order                  (application_order)
#  index_pricings_margins_on_cargo_class                        (cargo_class)
#  index_pricings_margins_on_destination_hub_id                 (destination_hub_id)
#  index_pricings_margins_on_effective_date                     (effective_date)
#  index_pricings_margins_on_expiration_date                    (expiration_date)
#  index_pricings_margins_on_itinerary_id                       (itinerary_id)
#  index_pricings_margins_on_margin_type                        (margin_type)
#  index_pricings_margins_on_organization_id                    (organization_id)
#  index_pricings_margins_on_origin_hub_id                      (origin_hub_id)
#  index_pricings_margins_on_pricing_id                         (pricing_id)
#  index_pricings_margins_on_sandbox_id                         (sandbox_id)
#  index_pricings_margins_on_tenant_id                          (tenant_id)
#  index_pricings_margins_on_tenant_vehicle_id                  (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
