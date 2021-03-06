# frozen_string_literal: true

module Shipments
  class Cargo < ApplicationRecord
    has_paper_trail

    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :shipment

    has_many :units

    def area
      units.map(&:total_area).sum(Measured::Area.new(0, :m2))
    end

    def quantity
      units.sum(:quantity)
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

    def lcl?
      units.all?(&:cargo_class_00?)
    end

    def consolidated?
      units.all?(&:cargo_type_AGR?)
    end

    def stowage_factor
      factor = volume.value / weight.convert_to(:t).value
      Measured::StowageFactor.new(factor.round(6), "m3/t")
    end
  end
end

# == Schema Information
#
# Table name: shipments_cargos
#
#  id                         :uuid             not null, primary key
#  total_goods_value_cents    :integer          default(0), not null
#  total_goods_value_currency :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  organization_id            :uuid
#  sandbox_id                 :uuid
#  shipment_id                :uuid
#  tenant_id                  :uuid
#
# Indexes
#
#  index_shipments_cargos_on_organization_id  (organization_id)
#  index_shipments_cargos_on_sandbox_id       (sandbox_id)
#  index_shipments_cargos_on_shipment_id      (shipment_id)
#  index_shipments_cargos_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
