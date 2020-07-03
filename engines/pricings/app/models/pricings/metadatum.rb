# frozen_string_literal: true

module Pricings
  class Metadatum < ApplicationRecord
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :charge_breakdown, class_name: 'Legacy::ChargeBreakdown'
    has_many :breakdowns, dependent: :destroy
    validates_uniqueness_of :charge_breakdown_id, scope: %(organization_id)
  end
end

# == Schema Information
#
# Table name: pricings_metadata
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cargo_unit_id       :integer
#  charge_breakdown_id :integer
#  organization_id     :uuid
#  pricing_id          :uuid
#  tenant_id           :uuid
#
# Indexes
#
#  index_pricings_metadata_on_charge_breakdown_id  (charge_breakdown_id)
#  index_pricings_metadata_on_organization_id      (organization_id)
#  index_pricings_metadata_on_tenant_id            (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
