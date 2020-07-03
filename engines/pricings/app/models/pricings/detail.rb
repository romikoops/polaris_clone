# frozen_string_literal: true

module Pricings
  class Detail < ApplicationRecord
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :margin
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :charge_category, class_name: 'Legacy::ChargeCategory'
    validates :operator, inclusion: { in: %w[+ % &],
                                      message: '%{value} is not a valid operator for a margin detail' }

    def rate_basis
      margin.get_pricing&.fees&.find_by(charge_category_id: charge_category_id)&.rate_basis&.external_code
    end

    delegate :itinerary_name, to: :margin

    def fee_code
      charge_category&.code
    end
  end
end

# == Schema Information
#
# Table name: pricings_details
#
#  id                 :uuid             not null, primary key
#  operator           :string
#  value              :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :integer
#  margin_id          :uuid
#  organization_id    :uuid
#  sandbox_id         :uuid
#  tenant_id          :uuid
#
# Indexes
#
#  index_pricings_details_on_charge_category_id  (charge_category_id)
#  index_pricings_details_on_margin_id           (margin_id)
#  index_pricings_details_on_organization_id     (organization_id)
#  index_pricings_details_on_sandbox_id          (sandbox_id)
#  index_pricings_details_on_tenant_id           (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
