# frozen_string_literal: true

FactoryBot.define do
  factory :container do
    size_class { 'fcl_20' } # TODO: set right size class
    weight_class { '14t' }
    payload_in_kg { 10_000 }
    tare_weight { 1000 }
    gross_weight { 11_000 }
    cargo_class { 'fcl_20' }
    dangerous_goods { false }
    quantity { 1 }
    association :shipment
  end
end

# == Schema Information
#
# Table name: containers
#
#  id              :bigint(8)        not null, primary key
#  shipment_id     :integer
#  size_class      :string
#  weight_class    :string
#  payload_in_kg   :decimal(, )
#  tare_weight     :decimal(, )
#  gross_weight    :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  dangerous_goods :boolean
#  cargo_class     :string
#  hs_codes        :string           default([]), is an Array
#  customs_text    :string
#  quantity        :integer
#  unit_price      :jsonb
#
