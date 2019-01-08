# frozen_string_literal: true


FactoryBot.define do
  factory :pricing_detail do
    rate 1111
    rate_basis 'PER_CONTAINER'
    shipping_type 'BAS'
    currency_name 'EUR'
  end

end

# == Schema Information
#
# Table name: pricing_details
#
#  id             :bigint(8)        not null, primary key
#  rate           :decimal(, )
#  rate_basis     :string
#  min            :decimal(, )
#  hw_threshold   :decimal(, )
#  hw_rate_basis  :string
#  shipping_type  :string
#  range          :jsonb
#  currency_name  :string
#  currency_id    :bigint(8)
#  priceable_type :string
#  priceable_id   :bigint(8)
#  tenant_id      :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
