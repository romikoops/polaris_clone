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
#  mode_of_transport  :string
#  load_type          :string
#  hub_id             :integer
#  tenant_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  tenant_vehicle_id  :integer
#  counterpart_hub_id :integer
#  direction          :string
#  fees               :jsonb
#
