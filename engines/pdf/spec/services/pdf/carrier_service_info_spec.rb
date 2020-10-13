# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::CarrierServiceInfo, type: :service do
  let(:tender) { FactoryBot.create(:quotations_tender, pickup_tenant_vehicle: tenant_vehicle) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle) }
  let(:carriage) { "pre" }
  let(:voyage_info) { {} }
  let(:result) { described_class.new(tender: tender, voyage_info: voyage_info, carriage: carriage).operator }

  context "with default settings" do
    it "limits the quotes returned when tender ids are provided" do
      expect(result).to eq("")
    end
  end

  context "with pickup carrier info settings" do
    let(:voyage_info) { {"pre_carriage_carrier" => true} }

    it "returns the carrier info in the correct format" do
      expect(result).to eq("Hapag Lloyd")
    end
  end

  context "with pickup service info settings" do
    let(:voyage_info) { {"pre_carriage_service" => true} }

    it "returns the carrier info in the correct format" do
      expect(result).to eq("standard")
    end
  end

  context "with pickup carrier and service info settings" do
    let(:voyage_info) { {"pre_carriage_service" => true, "pre_carriage_carrier" => true} }

    it "returns the carrier info in the correct format" do
      expect(result).to eq("Hapag Lloyd(standard)")
    end
  end
end
