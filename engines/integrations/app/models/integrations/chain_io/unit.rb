# frozen_string_literal: true

module Integrations
  module ChainIo
    class Unit < ::Cargo::Unit
      def containerization_type
        cargo_class == '00' ? 'LCL' : 'FCL'
      end

      def lcl?
        containerization_type == 'LCL'
      end

      def fcl?
        containerization_type == 'FCL'
      end

      def size_type_codes
        [cargo_class, cargo_type].join
      end

      def size_code
        size_type_codes
      end

      def type_code
        size_type_codes
      end
    end
  end
end

# == Schema Information
#
# Table name: cargo_units
#
#  id                   :uuid             not null, primary key
#  tenant_id            :uuid
#  quantity             :integer          default(0)
#  cargo_class          :bigint           default("00")
#  cargo_type           :bigint           default("LCL")
#  stackable            :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  weight_value         :decimal(100, 3)  default(0.0)
#  width_value          :decimal(100, 4)  default(0.0)
#  length_value         :decimal(100, 4)  default(0.0)
#  height_value         :decimal(100, 4)  default(0.0)
#  volume_value         :decimal(100, 6)  default(0.0)
#  volume_unit          :string           default("m3")
#  weight_unit          :string           default("kg")
#  width_unit           :string           default("m")
#  length_unit          :string           default("m")
#  height_unit          :string           default("m")
#  cargo_id             :uuid
#  dangerous_goods      :integer          default("unspecified")
#  goods_value_cents    :integer          default(0), not null
#  goods_value_currency :string           not null
#
