# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_remark, class: 'Legacy::Remark' do
    body { 'Some Remark' }
    association :tenant
    category { 'Quotation' }
    subcategory { 'Shipment' }
  end
end
