# frozen_string_literal: true

module Cargo
  class Cargo < ApplicationRecord
    belongs_to :organization, class_name: 'Organizations::Organization'
    has_many :units, class_name: 'Cargo::Unit'

    def total_area
      units.map(&:total_area).sum(Measured::Area.new(0, :m2))
    end

    def total_weight
      units.map(&:total_weight).sum(Measured::Weight.new(0, :kg))
    end

    def total_volume
      units.map(&:total_volume).sum(Measured::Volume.new(0, :m3))
    end

    def stackable?
      units.all?(&:stackable)
    end

    def stowage_factor
      factor = total_volume.value / total_weight.convert_to(:t).value
      Measured::StowageFactor.new(factor.round(6), 'm3/t')
    end

    def lcl?
      units.all?(&:cargo_class_00?)
    end

    def consolidated?
      units.all?(&:cargo_type_AGR?)
    end

    alias area total_area
    alias weight total_weight
    alias volume total_volume
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
#  organization_id            :uuid
#  quotation_id               :uuid
#  tenant_id                  :uuid
#
# Indexes
#
#  index_cargo_cargos_on_organization_id  (organization_id)
#  index_cargo_cargos_on_quotation_id     (quotation_id)
#  index_cargo_cargos_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
