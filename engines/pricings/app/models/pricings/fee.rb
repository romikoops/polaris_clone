# frozen_string_literal: true

module Pricings
  class Fee < ApplicationRecord
    include ::Pricings::Legacy
    has_paper_trail
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :pricing, class_name: '::Pricings::Pricing'
    belongs_to :rate_basis, class_name: '::Pricings::RateBasis'
    belongs_to :hw_rate_basis, class_name: '::Pricings::RateBasis', optional: true
    belongs_to :charge_category, class_name: 'Legacy::ChargeCategory'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    def to_fee_hash
      return unless charge_category.present?

      {
        fee_code => fee_data
      }.compact.with_indifferent_access
    end

    def fee_data
      {
        rate: rate,
        base: base,
        rate_basis: rate_basis&.internal_code,
        currency: currency_name,
        hw_threshold: hw_threshold,
        hw_rate_basis: hw_rate_basis&.internal_code,
        min: min,
        range: range
      }
    end

    def fee_code
      charge_category&.code
    end

    def fee_name
      charge_category&.name
    end

    def fee_name_and_code
      "#{fee_code&.upcase} - #{fee_name}"
    end
  end
end

# == Schema Information
#
# Table name: pricings_fees
#
#  id                 :uuid             not null, primary key
#  base               :decimal(, )
#  currency_name      :string
#  hw_threshold       :decimal(, )
#  metadata           :jsonb
#  min                :decimal(, )
#  range              :jsonb
#  rate               :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :integer
#  currency_id        :bigint
#  hw_rate_basis_id   :uuid
#  legacy_id          :integer
#  organization_id    :uuid
#  pricing_id         :uuid
#  rate_basis_id      :uuid
#  sandbox_id         :uuid
#  tenant_id          :bigint
#
# Indexes
#
#  index_pricings_fees_on_organization_id  (organization_id)
#  index_pricings_fees_on_pricing_id       (pricing_id)
#  index_pricings_fees_on_sandbox_id       (sandbox_id)
#  index_pricings_fees_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
