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

    def as_json(options = {})
      new_options = options.reverse_merge(
        methods: fee_code, only: []
      )
      super(new_options)
    end

    def to_fee
      {
        rate: rate,
        base: base,
        rate_basis: rate_basis&.internal_code,
        currency: currency_name,
        hw_threshold: hw_threshold,
        hw_rate_basis: hw_rate_basis&.internal_code,
        min: min,
        range: range
      }.compact.with_indifferent_access
    end

    def fee_code
      charge_category&.code
    end

    def fee_name
      charge_category&.name
    end

    def fee_name_and_code
      "#{charge_category&.code} - #{charge_category&.name}"
    end

    def method_missing(method_name, *args)
      if method_name == fee_code.to_sym
        to_fee
      else
        super
      end
    end

    def respond_to_missing?(method_name, *args)
      if method_name == fee_code.to_sym
        true
      else
        super
      end
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
#
