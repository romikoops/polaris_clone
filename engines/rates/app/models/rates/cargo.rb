# frozen_string_literal: true

module Rates
  class Cargo < ApplicationRecord
    enum cargo_class: ::Cargo::Specification::CLASS_ENUM, _prefix: true
    enum cargo_type: ::Cargo::Specification::TYPE_ENUM, _prefix: true
    enum operator: { min_value: 0, max_value: 1, sum_values: 2 }
    enum applicable_to: { self: 0, route_rate: 1, shipment: 2 }
    enum valid_at: { vatos: 0, vatoa: 1, vatob: 2 }

    belongs_to :section

    has_many :fees
  end
end

# == Schema Information
#
# Table name: rates_cargos
#
#  id            :uuid             not null, primary key
#  applicable_to :integer          default("self")
#  cargo_class   :integer          default("00")
#  cargo_type    :integer          default("LCL")
#  category      :integer          default(0)
#  cbm_ratio     :decimal(, )
#  code          :string
#  operator      :integer
#  order         :integer          default(0)
#  valid_at      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  section_id    :uuid
#
# Indexes
#
#  index_rates_cargos_on_cargo_class  (cargo_class)
#  index_rates_cargos_on_cargo_type   (cargo_type)
#  index_rates_cargos_on_category     (category)
#  index_rates_cargos_on_section_id   (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (section_id => rates_sections.id)
#
