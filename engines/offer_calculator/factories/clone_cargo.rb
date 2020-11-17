# frozen_string_literal: true

FactoryBot.define do
  factory :cloned_cargo, class: "Cargo::Cargo", parent: :cargo_cargo do
    after(:build) do |cargo|
      cargo.quotation_id = FactoryBot.create(:quotations_quotation).id if cargo.quotation_id.blank?
    end

    after(:create) do |cargo, evaluator|
      quotation = Quotations::Quotation.find_by(id: cargo.quotation_id)
      if quotation&.legacy_shipment_id.present?
        shipment = Legacy::Shipment.find(quotation.legacy_shipment_id)
        shipment.cargo_units.each do |legacy_unit|
          FactoryBot.create("#{legacy_unit.cargo_class}_unit", legacy: legacy_unit, cargo: cargo)
        end
      end
    end
  end
end
