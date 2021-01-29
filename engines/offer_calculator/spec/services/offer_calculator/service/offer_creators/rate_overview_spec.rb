# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::RateOverview do
  include_context "journey_pdf_setup"
  include_context "journey_legacy_models"
  let(:decorated_result) { ResultFormatter::ResultDecorator.new(result) }
  let(:rate_overview) { described_class.new(result: decorated_result).perform }

  describe ".perform" do
    context "when a single rate" do
      let(:journey_load_type) { :lcl }
      let(:fee) { pricing.fees.first }
      let(:expected_overview) do
        {
          pricing.cargo_class => {
            fee.fee_code.downcase => fee.fee_data
          }
        }.deep_stringify_keys
      end

      it "returns a the valid from date" do
        expect(rate_overview).to eq(expected_overview)
      end
    end

    context "when a other cargo classes available in load type" do
      let(:journey_load_type) { :fcl }
      let(:pricing) {
        FactoryBot.create(:pricings_pricing,
          :fcl_20,
          tenant_vehicle: tenant_vehicle,
          itinerary: itinerary,
          organization: organization)
      }
      let(:fcl_40_pricing) {
        FactoryBot.create(:pricings_pricing,
          :fcl_40,
          tenant_vehicle: tenant_vehicle,
          itinerary: itinerary,
          organization: organization)
      }
      let(:fcl_40_hq_pricing) {
        FactoryBot.create(:pricings_pricing,
          :fcl_40_hq,
          tenant_vehicle: tenant_vehicle,
          itinerary: itinerary,
          organization: organization)
      }
      let(:fee) { pricing.fees.first }
      let!(:fcl_40_fee) { fcl_40_pricing.fees.first }
      let!(:fcl_40_hq_fee) { fcl_40_hq_pricing.fees.first }
      let(:expected_overview) do
        {
          pricing.cargo_class => {
            fee.fee_code.downcase => fee.fee_data
          },
          fcl_40_pricing.cargo_class => {
            fcl_40_fee.fee_code.downcase => fcl_40_fee.fee_data
          },
          fcl_40_hq_pricing.cargo_class => {
            fcl_40_hq_fee.fee_code.downcase => fcl_40_hq_fee.fee_data
          }
        }.deep_stringify_keys
      end

      it "returns a the valid from date" do
        expect(rate_overview).to eq(expected_overview)
      end
    end
  end
end
