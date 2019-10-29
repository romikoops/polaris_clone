# frozen_string_literal: true

FactoryBot.define do
  factory :sequential_sequence, class: 'Sequential::Sequence' do
    name { :shipment_invoice_number }
  end
end
