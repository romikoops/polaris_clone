require 'rails_helper'

RSpec.describe OfferCalculatorService::ChargeCalculator do
  describe "#perform", :vcr do
    include SetupHelper 
    json_test = test_cases_from_excel("#{Rails.root}/spec/test_sheets/spec_sheet.xlsx", "Sheet1")
    # json_test = test_cases_from_json("#{Rails.root}/spec/test_sheets/spec_sheet.json")

    json_test.each do |test|
      test = test.deep_symbolize_keys
      it "should have a total price of #{test[:target_price]} and currency is #{test[:target_currency]}" do
        setup = variables_setup(test)
        request_stubber('6985c41eadad14bbab851c518745c236', test[:target_currency])
        shipment = setup[:_shipment]
        schedule = setup[:_schedule]
        user = setup[:_user]
        offer_charge = OfferCalculatorService::ChargeCalculator.new(
          shipment:      shipment,
          trucking_data: {},
          schedule:      schedule,
          user:          user

        ).perform
        expect(offer_charge.price.value.to_f).to eq(test[:target_price])
        expect(offer_charge.price.currency).to eq(test[:target_currency])
      end
    end
  end
end
