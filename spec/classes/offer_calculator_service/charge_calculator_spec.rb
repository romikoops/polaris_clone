require 'rails_helper'

RSpec.describe OfferCalculatorService::ChargeCalculator do
  describe "#perform", :vcr do
    include SetupHelper

    it "should calculate correct shipping charge" do
      setup = variables_setup(trucking: {"on_carriage"=>{"truck_type"=>""}, "pre_carriage"=>{"truck_type"=>""}})
      request_stubber('6985c41eadad14bbab851c518745c236', 'EUR')
      shipment = setup[:_shipment]
      schedule = setup[:_schedule]
      user = setup[:_user]
      offer_charge = OfferCalculatorService::ChargeCalculator.new(
        shipment:      shipment,
        trucking_data: {},
        schedule:      schedule,
        user:          user
      ).perform

      shipment_charge = shipment.charge_breakdowns.selected.charge("grand_total").price.value
      expect(offer_charge.price.value).to eq(shipment_charge)
    end
  end
end
