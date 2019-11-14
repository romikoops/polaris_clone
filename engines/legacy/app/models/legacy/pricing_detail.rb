# frozen_string_literal: true

module Legacy
  class PricingDetail < ApplicationRecord
    self.table_name = 'pricing_details'

    belongs_to :tenant
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
#  id             :bigint           not null, primary key
#  rate           :decimal(, )
#  rate_basis     :string
#  min            :decimal(, )
#  hw_threshold   :decimal(, )
#  hw_rate_basis  :string
#  shipping_type  :string
#  range          :jsonb
#  currency_name  :string
#  currency_id    :bigint
#  priceable_type :string
#  priceable_id   :bigint
#  tenant_id      :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  sandbox_id     :uuid
#
