# frozen_string_literal: true

module Cargo
  class Cargo < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :units, class_name: 'Cargo::Unit'

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
# Table name: cargo_cargos
#
#  id           :uuid             not null, primary key
#  tenant_id    :uuid
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  quotation_id :uuid
#
