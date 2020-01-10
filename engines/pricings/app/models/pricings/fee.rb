# frozen_string_literal: true

module Pricings
  class Fee < ApplicationRecord
    include ::Pricings::Legacy
    has_paper_trail
    belongs_to :tenant, class_name: 'Legacy::Tenant'
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
#  rate               :decimal(, )
#  base               :decimal(, )
#  rate_basis_id      :uuid
#  min                :decimal(, )
#  hw_threshold       :decimal(, )
#  hw_rate_basis_id   :uuid
#  charge_category_id :integer
#  range              :jsonb
#  currency_name      :string
#  currency_id        :bigint
#  pricing_id         :uuid
#  tenant_id          :bigint
#  legacy_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  sandbox_id         :uuid
#  metadata           :jsonb
#
