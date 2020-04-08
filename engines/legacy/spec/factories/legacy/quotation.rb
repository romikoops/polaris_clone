# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_quotation, class: 'Legacy::Quotation' do
    association :user, factory: :legacy_user
    transient do
      shipment_count { 1 }
      load_type { 'cargo_item' }
    end

    target_email { 'john@example.test' }
    name { 'NAME' }

    after(:create) do |quotation, evaluator|
      if quotation.original_shipment_id.nil?
        original_shipment = create(:legacy_shipment,
                                   user: quotation.user,
                                   tenant: quotation.user.tenant,
                                   load_type: evaluator.load_type,
                                   with_breakdown: true)
        quotation.original_shipment_id = original_shipment.id
      end
      if quotation.shipments.empty?
        quotation.shipments = create_list(:legacy_shipment, evaluator.shipment_count,
                                          user: quotation.user,
                                          tenant: quotation.user.tenant,
                                          load_type: evaluator.load_type,
                                          with_breakdown: true)
      end
    end
  end
end
