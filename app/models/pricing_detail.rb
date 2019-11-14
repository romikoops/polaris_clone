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
