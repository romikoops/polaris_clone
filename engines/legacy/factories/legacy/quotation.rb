# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_quotation, class: "Legacy::Quotation" do
    transient do
      shipment_count { 1 }
      load_type { "cargo_item" }
    end

    user { association(:users_client) }
    original_shipment { association(:legacy_shipment) }

    target_email { "john@example.test" }
    name { "NAME" }
    billing { :external }

    before(:create) do |quotation, evaluator|
      if quotation.original_shipment_id.nil?
        original_shipment = create(:legacy_shipment,
          user: quotation.user,
          organization: quotation.user.organization,
          load_type: evaluator.load_type,
          with_breakdown: true,
          with_tenders: true)
        quotation.original_shipment_id = original_shipment.id
      end
      if quotation.shipments.empty?
        quotation.shipments = create_list(:legacy_shipment, evaluator.shipment_count,
          user: quotation.user,
          organization: quotation.user.organization,
          load_type: evaluator.load_type,
          with_breakdown: true,
          with_tenders: true)
      end
    end
  end
end
