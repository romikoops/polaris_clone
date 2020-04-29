# frozen_string_literal: true

FactoryBot.define do
  factory :rates_section, class: 'Rates::Section' do
    association :tenant, factory: :tenants_tenant
    association :target, factory: :routing_route_line_service
    ldm_area_divisor { 2.4 }
    truck_height { 2.6 }

    ldm_ratio { 1000 }

    trait :with_lcl_cargo_rate do
      after(:build) do |section|
        create :rates_cargo, :lcl, section: section
      end
    end

    trait :with_fcl_20_cargo_rate do
      after(:build) do |section|
        create :rates_cargo, :container_20, section: section
      end
    end

    trait :with_fcl_40_cargo_rate do
      after(:build) do |section|
        create :rates_cargo, :container_40, section: section
      end
    end

    factory :section_lcl_rate, traits: %i[with_lcl_cargo_rate]
    factory :section_for_multiple_cargo_classes, traits: %i[with_lcl_cargo_rate with_fcl_20_cargo_rate with_fcl_40_cargo_rate]
  end
end

# == Schema Information
#
# Table name: rates_sections
#
#  id                       :uuid             not null, primary key
#  disabled                 :boolean
#  ldm_area_divisor         :decimal(, )
#  ldm_measurement          :integer
#  ldm_ratio                :decimal(, )      default(0.0)
#  ldm_threshold            :decimal(, )      default(0.0)
#  ldm_threshold_applicable :integer
#  mode_of_transport        :integer
#  target_type              :string
#  truck_height             :decimal(, )
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  carrier_id               :uuid
#  location_id              :uuid
#  target_id                :uuid
#  tenant_id                :uuid
#  terminal_id              :uuid
#
# Indexes
#
#  index_rates_sections_on_carrier_id                 (carrier_id)
#  index_rates_sections_on_location_id                (location_id)
#  index_rates_sections_on_target_type_and_target_id  (target_type,target_id)
#  index_rates_sections_on_tenant_id                  (tenant_id)
#  index_rates_sections_on_terminal_id                (terminal_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => routing_locations.id)
#  fk_rails_...  (tenant_id => tenants_tenants.id)
#  fk_rails_...  (terminal_id => routing_terminals.id)
#
