# frozen_string_literal: true

module Shipments
  class Unit < ApplicationRecord
    has_paper_trail

    measured_weight :weight
    measured_volume :volume
    measured_length :width, :length, :height

    enum cargo_class: ::Cargo::Specification::CLASS_ENUM, _prefix: true
    enum cargo_type: ::Cargo::Specification::TYPE_ENUM, _prefix: true
    enum dangerous_goods: {
      unspecified: 0
    }

    belongs_to :cargo

    validates :weight, measured: { units: :kg }
    validates :volume, measured: { units: :m3 }
    validates :width, :length, :height, measured: { units: :m }
    validates_presence_of %i(quantity cargo_class cargo_type)
    %i(weight width length height volume).each do |attr|
      validates attr, measured: true
    end

    before_validation :ensure_si_units

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
      self.width = width.convert_to('m') unless width.nil?
      self.length = length.convert_to('m') unless length.nil?
      self.height = height.convert_to('m') unless height.nil?
    end
  end
end

# == Schema Information
#
# Table name: shipments_units
#
#  id                   :uuid             not null, primary key
#  cargo_class          :bigint
#  cargo_type           :bigint
#  dangerous_goods      :integer          default("unspecified")
#  goods_value_cents    :integer          default(0), not null
#  goods_value_currency :string           not null
#  height_unit          :string           default("m")
#  height_value         :decimal(100, 4)
#  length_unit          :string           default("m")
#  length_value         :decimal(100, 4)
#  quantity             :integer          not null
#  stackable            :boolean
#  volume_unit          :string           default("m3")
#  volume_value         :decimal(100, 6)
#  weight_unit          :string           default("kg")
#  weight_value         :decimal(100, 3)
#  width_unit           :string           default("m")
#  width_value          :decimal(100, 4)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  cargo_id             :uuid             not null
#  sandbox_id           :uuid
#
# Indexes
#
#  index_shipments_units_on_cargo_id    (cargo_id)
#  index_shipments_units_on_sandbox_id  (sandbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
