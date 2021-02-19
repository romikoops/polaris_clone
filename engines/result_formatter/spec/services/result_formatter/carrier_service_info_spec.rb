# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::CarrierServiceInfo, type: :service do
  let(:result) { FactoryBot.create(:journey_result) }
  let(:decorated_result) { ResultFormatter::ResultDecorator.new(FactoryBot.create(:journey_result)) }
  let(:pre_carriage_section) do
    FactoryBot.create(:journey_route_section,
      result: result,
      mode_of_transport: "carriage",
      order: 0,
      service: "standard",
      carrier: "Hapag Lloyd")
  end
  let(:carriage) { "pre" }
  let(:voyage_info) { {} }
  let(:operator_string) { described_class.new(result: decorated_result, voyage_info: voyage_info, carriage: carriage).operator }

  before do
    allow(decorated_result).to receive(:pre_carriage_section).and_return(pre_carriage_section)
  end

  context "with default settings" do
    it "limits the quotes returned when tender ids are provided" do
      expect(operator_string).to eq("")
    end
  end

  context "with pickup carrier info settings" do
    let(:voyage_info) { {"pre_carriage_carrier" => true} }

    it "returns the carrier info in the correct format" do
      expect(operator_string).to eq("Hapag Lloyd")
    end
  end

  context "with pickup service info settings" do
    let(:voyage_info) { {"pre_carriage_service" => true} }

    it "returns the carrier info in the correct format" do
      expect(operator_string).to eq("standard")
    end
  end

  context "with pickup carrier and service info settings" do
    let(:voyage_info) { {"pre_carriage_service" => true, "pre_carriage_carrier" => true} }

    it "returns the carrier info in the correct format" do
      expect(operator_string).to eq("Hapag Lloyd(standard)")
    end
  end
end
