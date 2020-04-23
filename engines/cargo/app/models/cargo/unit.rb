# frozen_string_literal: true

module Cargo
  class Unit < ApplicationRecord
    measured_weight :weight
    measured_volume :volume
    measured_length :width, :length, :height
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :cargo, class_name: 'Cargo::Cargo'

    enum cargo_class: Specification::CLASS_ENUM, _prefix: true
    enum cargo_type: Specification::TYPE_ENUM, _prefix: true
    enum dangerous_goods: {
      unspecified: 0
    }

    validates :tenant_id, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :weight, measured: { units: :kg, greater_than: 0 }
    validates :volume, measured: { units: :m3 }
    validates :width, :length, :height, measured: { units: :m }
    validates :width, :length, :height, measured: { greater_than: 0 }, if: :requires_dimensions?

    before_validation :ensure_si_units

    before_validation :set_volume_and_height

    def area
      Measured::Area.new(volume_value / height_value, :m2)
    end

    def total_area
      area.scale(quantity)
    end

    def total_volume
      volume.scale(quantity)
    end

    def total_weight
      weight.scale(quantity)
    end

    def stowage_factor
      factor = total_volume.value / total_weight.convert_to(:t).value
      Measured::StowageFactor.new(factor.round(6), 'm3/t')
    end

    private

    def ensure_si_units
      self.weight = weight.convert_to('kg')
      self.volume = volume.convert_to('m3')
      self.width = width.convert_to('m')
      self.length = length.convert_to('m')
      self.height = height.convert_to('m')
    end

    def requires_dimensions?
      cargo_class_00? && cargo_type_LCL?
    end

    def set_volume_and_height
      return true unless cargo_class == '00'

      if cargo_type == 'AGR'
        self.height_value = Specification::DEFAULT_HEIGHT if height_value.zero?
      else
        self.volume_value = (width_value * length_value * height_value)
      end
    end
  end
end

# == Schema Information
#
# Table name: cargo_units
#
#  id                   :uuid             not null, primary key
#  cargo_class          :bigint           default("00")
#  cargo_type           :bigint           default("LCL")
#  dangerous_goods      :integer          default("unspecified")
#  goods_value_cents    :integer          default(0), not null
#  goods_value_currency :string           not null
#  height_unit          :string           default("m")
#  height_value         :decimal(100, 4)  default(0.0)
#  length_unit          :string           default("m")
#  length_value         :decimal(100, 4)  default(0.0)
#  quantity             :integer          default(0)
#  stackable            :boolean          default(FALSE)
#  volume_unit          :string           default("m3")
#  volume_value         :decimal(100, 6)  default(0.0)
#  weight_unit          :string           default("kg")
#  weight_value         :decimal(100, 3)  default(0.0)
#  width_unit           :string           default("m")
#  width_value          :decimal(100, 4)  default(0.0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  cargo_id             :uuid
#  tenant_id            :uuid
#
# Indexes
#
#  index_cargo_units_on_cargo_class  (cargo_class)
#  index_cargo_units_on_cargo_id     (cargo_id)
#  index_cargo_units_on_cargo_type   (cargo_type)
#  index_cargo_units_on_tenant_id    (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_id => cargo_cargos.id)
#
