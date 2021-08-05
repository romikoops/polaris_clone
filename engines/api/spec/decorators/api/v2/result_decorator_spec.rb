# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ResultDecorator do
  let(:result) { FactoryBot.create(:journey_result) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_result) { described_class.new(result, context: { scope: scope }) }
  let!(:routing_carrier) { FactoryBot.create(:routing_carrier, with_logo: with_logo, name: result.route_sections.first.carrier) }
  let(:with_logo) { true }

  describe ".carrier_logo" do
    context "with logo attached" do
      it "returns the url for accessing the logo of the freight carrier" do
        expect(decorated_result.carrier_logo).to include("test-image.jpg")
      end
    end

    context "without logo attached" do
      let(:with_logo) { false }

      it "returns the url for accessing the logo of the freight carrier" do
        expect(decorated_result.carrier_logo).to be_nil
      end
    end
  end

  describe ".routing_carrier" do
    it "returns the Routing::Carrier based off the main freight Section" do
      expect(decorated_result.routing_carrier).to eq(routing_carrier)
    end
  end
end
