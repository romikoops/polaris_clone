# frozen_string_literal: true

FactoryBot.define do
  factory :offer_creator_offer, class: "OfferCalculator::Service::OfferCreators::Offer" do
    skip_create
    shipment { FactoryBot.create(:legacy_shipment) }
    quotation { FactoryBot.create(quotations_quotation, legacy_shipment_id: shipment.id) }
    schedules { [] }
    results { [] }

    initialize_with do
      OfferCalculator::Service::OfferCreators::Offer.new(
        shipment: shipment,
        quotation: quotation,
        schedules: schedules,
        offer: results.group_by(&:section)
      )
    end
  end
end
