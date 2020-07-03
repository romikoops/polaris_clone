# frozen_string_literal: true

module Legacy
  class PricingDetail < ApplicationRecord
    self.table_name = 'pricing_details'

    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :priceable, polymorphic: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    def to_fee_hash
      {
        shipping_type => {
          rate: rate,
          rate_basis: rate_basis,
          currency: currency_name,
          hw_threshold: hw_threshold,
          hw_rate_basis: hw_rate_basis,
          min: min,
          range: range
        }
      }.compact.with_indifferent_access
    end
  end
end

# == Schema Information
#
# Table name: pricing_details
#
#  id              :bigint           not null, primary key
#  currency_name   :string
#  hw_rate_basis   :string
#  hw_threshold    :decimal(, )
#  min             :decimal(, )
#  priceable_type  :string
#  range           :jsonb
#  rate            :decimal(, )
#  rate_basis      :string
#  shipping_type   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  currency_id     :bigint
#  organization_id :uuid
#  priceable_id    :bigint
#  sandbox_id      :uuid
#  tenant_id       :bigint
#
# Indexes
#
#  index_pricing_details_on_currency_id                      (currency_id)
#  index_pricing_details_on_organization_id                  (organization_id)
#  index_pricing_details_on_priceable_type_and_priceable_id  (priceable_type,priceable_id)
#  index_pricing_details_on_sandbox_id                       (sandbox_id)
#  index_pricing_details_on_tenant_id                        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
