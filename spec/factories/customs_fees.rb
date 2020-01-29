# frozen_string_literal: true

FactoryBot.define do
  factory :customs_fee do
    load_type { 'lcl' }
    mode_of_transport { 'ocean' }
    association :tenant
    association :tenant_vehicle
    counterpart_hub_id { nil }
    direction { 'export' }
    fees do
      {
        'CUST' => {
          'key' => 'CUST',
          'max' => nil,
          'name' => 'Customs Clearance',
          'value' => 150.0,
          'currency' => 'CNY',
          'rate_basis' => 'PER_SHIPMENT',
          'effective_date' => '2018-12-13',
          'expiration_date' => '2018-12-31'
        }
      }
    end
  end
end

# == Schema Information
#
# Table name: customs_fees
#
#  id                 :bigint           not null, primary key
#  direction          :string
#  fees               :jsonb
#  load_type          :string
#  mode_of_transport  :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  counterpart_hub_id :integer
#  hub_id             :integer
#  tenant_id          :integer
#  tenant_vehicle_id  :integer
#
# Indexes
#
#  index_customs_fees_on_tenant_id  (tenant_id)
#
