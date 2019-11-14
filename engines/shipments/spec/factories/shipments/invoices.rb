# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_invoice, class: 'Shipments::Invoice' do
    amount_cents { 1000 }

    after(:build) do
      Sequential::Sequence.where(name: :shipment_invoice_number, value: 0).first_or_create
    end
  end
end
