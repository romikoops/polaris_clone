# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculatorService::ChargeCalculator do
  describe '#perform', :vcr do
    include SetupHelper
    # json_test = test_cases_from_excel("#{Rails.root}/spec/test_sheets/spec_sheet.xlsx", "Sheet1")
    json_test = test_cases_from_json("#{Rails.root}/spec/test_sheets/spec_sheet.json")
    json_test.each do |test|
      test = test.deep_symbolize_keys
      it "should have a total price of #{test[:target_price]} and currency is #{test[:target_currency]}", pending: 'Outdated spec' do
        setup = variables_setup(test, true)
        request_stubber('6985c41eadad14bbab851c518745c236', test[:target_currency])
        shipment = setup[:_shipment]
        schedule = setup[:_schedule]
        user = setup[:_user]
        carriage = setup[:_carriage]
        destination_hub = setup[:_destination_hub]
        origin_hub = setup[:_origin_hub]
        final_destination = setup[:_final_destination]
        origin_trcking = setup[:_origin_trucking]

        shipment.trucking['on_carriage']['address_id'] = final_destination.id if carriage == 'on'
        shipment.trucking['pre_carriage']['address_id'] = origin_trcking.id if carriage == 'pre'
        shipment.save!
        @trucking_data_builder = OfferCalculatorService::TruckingDataBuilder.new(shipment)
        c_hub = { origin: [origin_hub.id], destination: [destination_hub.id] }
        @trucking_data = @trucking_data_builder.perform(c_hub)
        offer_charge = OfferCalculatorService::ChargeCalculator.new(
          shipment:      shipment,
          trucking_data: @trucking_data,
          schedule:      schedule,
          user:          user
        ).perform

        expect(offer_charge.price.value.to_f.round(2)).to eq(test[:target_price])
        expect(offer_charge.price.currency).to eq(test[:target_currency])
      end
    end
  end
end
