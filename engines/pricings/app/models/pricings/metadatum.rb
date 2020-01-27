# frozen_string_literal: true

module Pricings
  class Metadatum < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :charge_breakdown, class_name: 'Legacy::ChargeBreakdown'
    has_many :breakdowns, dependent: :destroy
    validates_uniqueness_of :charge_breakdown_id, scope: %(tenant_id)
  end
end

# == Schema Information
#
# Table name: pricings_metadata
#
#  id                  :uuid             not null, primary key
#  pricing_id          :uuid
#  charge_breakdown_id :integer
#  cargo_unit_id       :integer
#  tenant_id           :uuid
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
