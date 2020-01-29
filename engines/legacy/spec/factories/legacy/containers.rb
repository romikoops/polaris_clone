# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_container, class: 'Legacy::Container' do
    size_class { 'fcl_20' }
    weight_class { '14t' }
    payload_in_kg { 10_000 }
    tare_weight { 1000 }
    gross_weight { 11_000 }
    cargo_class { 'fcl_20' }
    dangerous_goods { false }
    quantity { 1 }
    association :shipment, factory: :legacy_shipment
  end
end

# == Schema Information
#
# Table name: containers
#
#  id              :bigint           not null, primary key
#  cargo_class     :string
#  customs_text    :string
#  dangerous_goods :boolean
#  gross_weight    :decimal(, )
#  hs_codes        :string           default([]), is an Array
#  payload_in_kg   :decimal(, )
#  quantity        :integer
#  size_class      :string
#  tare_weight     :decimal(, )
#  unit_price      :jsonb
#  weight_class    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sandbox_id      :uuid
#  shipment_id     :integer
#
# Indexes
#
#  index_containers_on_sandbox_id  (sandbox_id)
#
