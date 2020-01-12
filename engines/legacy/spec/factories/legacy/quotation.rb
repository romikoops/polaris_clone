# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_quotation, class: 'Legacy::Quotation' do
    association :user, factory: :legacy_user
    transient do
      shipment_count { 1 }
    end

    target_email { 'john@example.test' }
    name { 'NAME' }

    after(:build) do |quotation, evaluator|
      quotation.shipments = create_list(:legacy_shipment, evaluator.shipment_count, 
        user: quotation.user,
        tenant: quotation.user.tenant,
        with_breakdown: true
      )
    end
  end
end
