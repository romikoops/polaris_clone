# frozen_string_literal: true

module Rates
  class Section < ApplicationRecord
    enum mode_of_transport: { ocean: 1, air: 2, rail: 3, truck: 4, carriage: 5 }
    enum ldm_threshold_applicable: { unit: 0, consolidated: 1 }
    enum ldm_measurement: { height: 0, area: 1, stacked_area: 2, load_meters: 3 }
    belongs_to :target, polymorphic: true
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :location, class_name: 'Routing::Location', optional: true
    belongs_to :terminal, class_name: 'Routing::Terminal', optional: true

    has_many :cargos
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
#  carrier_id               :bigint
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
#  fk_rails_...  (carrier_id => carriers.id)
#  fk_rails_...  (location_id => routing_locations.id)
#  fk_rails_...  (tenant_id => tenants_tenants.id)
#  fk_rails_...  (terminal_id => routing_terminals.id)
#
