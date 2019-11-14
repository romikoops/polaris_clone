# frozen_string_literal: true

module Shipments
  class Cargo < ApplicationRecord
    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :shipment

    has_many :units

    def area
      units.map(&:total_area).sum(Measured::Area.new(0, :m2))
    end

    def weight
      units.map(&:total_weight).sum(Measured::Weight.new(0, :kg))
    end

    def volume
      units.map(&:total_volume).sum(Measured::Volume.new(0, :m3))
    end

    def stackable?
      units.all?(&:stackable)
    end

    def stowage_factor
      factor = volume.value / weight.convert_to(:t).value
      Measured::StowageFactor.new(factor.round(6), 'm3/t')
    end
  end
end

# == Schema Information
#
# Table name: shipments_cargos
#
#  id                         :uuid             not null, primary key
#  sandbox_id                 :uuid
#  shipment_id                :uuid
#  tenant_id                  :uuid
#  total_goods_value_cents    :integer          default(0), not null
#  total_goods_value_currency :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
