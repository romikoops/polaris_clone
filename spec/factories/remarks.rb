# frozen_string_literal: true

FactoryBot.define do
  factory :remark do
    body 'Some Remark'
    association :tenant
    category 'Quotation'
    subcategory 'Shipment'
  end
end
