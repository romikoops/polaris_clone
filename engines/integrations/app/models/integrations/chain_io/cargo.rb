# frozen_string_literal: true

module Integrations
  module ChainIo
    class Cargo < Cargo::Cargo
      has_many :units

      def containerization_type
        units.map(&:containerization_type).uniq.sort.join(',')
      end

      def prepare_units
        packages = []
        containers = []

        units.each do |unit|
          if unit.lcl?
            packages.push(
              package_quantity: unit.quantity,
              description_of_goods: '',
              gross_weight_kgs: unit.total_weight.value.to_s('F'),
              volume_cbms: unit.volume.value.to_s('F')
            )
          elsif unit.fcl?
            containers.push(
              container_number: '',
              delivery_mode: '',
              size_code: unit.size_code,
              type_code: unit.type_code
            )
          end
        end

        { containers: containers, packages: packages }
      end
    end
  end
end

# == Schema Information
#
# Table name: cargo_cargos
#
#  id                         :uuid             not null, primary key
#  total_goods_value_cents    :integer          default(0), not null
#  total_goods_value_currency :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  quotation_id               :uuid
#  tenant_id                  :uuid
#
# Indexes
#
#  index_cargo_cargos_on_quotation_id  (quotation_id)
#  index_cargo_cargos_on_tenant_id     (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
