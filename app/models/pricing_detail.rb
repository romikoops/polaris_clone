# frozen_string_literal: true

class PricingDetail < Legacy::PricingDetail
  has_paper_trail
  belongs_to :tenant
  belongs_to :priceable, polymorphic: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
end

# == Schema Information
#
# Table name: pricing_details
#
#  id             :bigint           not null, primary key
#  currency_name  :string
#  hw_rate_basis  :string
#  hw_threshold   :decimal(, )
#  min            :decimal(, )
#  priceable_type :string
#  range          :jsonb
#  rate           :decimal(, )
#  rate_basis     :string
#  shipping_type  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  currency_id    :bigint
#  priceable_id   :bigint
#  sandbox_id     :uuid
#  tenant_id      :bigint
#
# Indexes
#
#  index_pricing_details_on_currency_id                      (currency_id)
#  index_pricing_details_on_priceable_type_and_priceable_id  (priceable_type,priceable_id)
#  index_pricing_details_on_sandbox_id                       (sandbox_id)
#  index_pricing_details_on_tenant_id                        (tenant_id)
#
