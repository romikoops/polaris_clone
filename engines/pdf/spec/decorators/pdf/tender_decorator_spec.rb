# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::TenderDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }

  let(:load_type) { "cargo_item" }
  let!(:shipment) do
    FactoryBot.create(:complete_legacy_shipment,
      organization: organization,
      user: user,
      load_type: load_type,
      with_breakdown: true,
      with_tenders: true,
      with_full_breakdown: true)
  end
  let(:chargeable_weight_view) { "volume" }
  let(:scope_content) { {"show_chargeable_weight" => true, "chargeable_weight_view" => chargeable_weight_view} }
  let(:scope) { OrganizationManager::ScopeService.new(target: user, organization: organization).fetch }
  let(:tender) { Quotations::Tender.last }
  let(:charge_breakdown) { shipment.charge_breakdowns.find_by(tender_id: tender.id) }
  let(:cargo) { tender.cargo }
  let(:klass) { described_class.decorate(tender, context: {scope: scope, tender: tender}) }

  before do
    Draper::ViewContext.controller = Pdf::ApplicationController.new

    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
    FactoryBot.create(:organizations_scope, target: organization, content: scope_content)
    shipment.charge_breakdowns.map(&:tender).each do |tender|
      Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                  to: "USD", rate: 1.3,
                                  created_at: tender.created_at - 30.seconds)
    end
  end

  describe ".carriage_service_string" do
    let(:result) { klass.carriage_service_string(carriage: "pre") }

    context "with default settings" do
      it "limits the quotes returned when tender ids are provided" do
        expect(result).to eq("")
      end
    end

    context "with pickup carrier info settings" do
      let(:scope_content) { {"voyage_info" => {"pre_carriage_carrier" => true}} }

      it "returns the carrier info in the correct format" do
        expect(result).to eq("operated by Hapag Lloyd")
      end
    end

    context "with pickup service info settings" do
      let(:scope_content) { {"voyage_info" => {"pre_carriage_service" => true}} }

      it "returns the carrier info in the correct format" do
        expect(result).to eq("operated by standard")
      end
    end

    context "with pickup carrier and service info settings" do
      let(:scope_content) { {"voyage_info" => {"pre_carriage_service" => true, "pre_carriage_carrier" => true}} }

      it "returns the carrier info in the correct format" do
        expect(result).to eq("operated by Hapag Lloyd(standard)")
      end
    end
  end

  describe ".currency" do
    it "returns the tender currency" do
      expect(klass.currency).to eq(tender.amount_currency)
    end
  end

  describe ".currencies" do
    it "returns the tender currencies" do
      expect(klass.currencies).to eq(tender.line_items.pluck(:amount_currency).uniq)
    end
  end

  describe ".voyage_code" do
    it "returns the trip voyage_code" do
      expect(klass.voyage_code).to eq(charge_breakdown.trip.voyage_code)
    end
  end

  describe ".export?" do
    it "returns true if export fees are present" do
      expect(klass.export?).to be_truthy
    end
  end

  describe ".import?" do
    it "returns true if import fees are present" do
      expect(klass.import?).to be_truthy
    end
  end

  describe ".addons?" do
    it "returns true if addons fees are present" do
      expect(klass.addons?).to be_falsy
    end
  end

  describe ".insurance?" do
    it "returns true if insurance fees are present" do
      expect(klass.insurance?).to be_falsy
    end
  end

  describe ".customs?" do
    it "returns true if customs fees are present" do
      expect(klass.customs?).to be_falsy
    end
  end

  describe ".pre_carriage_service" do
    it "returns the pre carriage service" do
      expect(klass.pre_carriage_service).to eq("")
    end
  end

  describe ".chargeable_weight_string" do
    context "when import/export" do
      it "returns an empty string" do
        expect(klass.chargeable_weight_string(section: "import")).to eq("")
      end
    end

    context "when cargo" do
      it "returns the chargeable weight string" do
        expect(klass.chargeable_weight_string(section: "cargo")).to eq("<small class='chargeable_weight'> (Chargeable Volume: 1.34 m<sup>3</sup></small>")
      end
    end

    context "when trucking" do
      before do
        shipment.update(trucking: {pre_carriage: {chargeable_weight: 500}})
      end

      it "returns the chargeable weight string" do
        expect(klass.chargeable_weight_string(section: "trucking_pre")).to eq("<small class='chargeable_weight'> (Chargeable Weight: 500 kg)</small>")
      end
    end
  end

  context "with trucking" do
    before do
      tender.quotation.update(
        pickup_address: address,
        delivery_address: address
      )
      tender.update(
        pickup_tenant_vehicle: truck_tenant_vehicle,
        delivery_tenant_vehicle: truck_tenant_vehicle
      )
    end

    let(:address) { FactoryBot.create(:legacy_address) }
    let(:truck_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
    let(:scope_content) do
      {
        "voyage_info" => {
          "pre_carriage_service" => true,
          "pre_carriage_carrier" => true,
          "on_carriage_service" => true,
          "on_carriage_carrier" => true
        }
      }
    end

    describe ".pre_carriage_service" do
      it "returns the pre carriage service" do
        expect(klass.pre_carriage_service).to eq("operated by Hapag Lloyd(standard)")
      end
    end

    describe ".on_carriage_service" do
      it "returns the on carriage service" do
        expect(klass.on_carriage_service).to eq("operated by Hapag Lloyd(standard)")
      end
    end

    describe ".full_pickup_address" do
      it "returns the pre carriage service" do
        expect(klass.full_pickup_address).to eq(address.full_address)
      end
    end

    describe ".full_delivery_address" do
      it "returns the on delivery_address" do
        expect(klass.full_delivery_address).to eq(address.full_address)
      end
    end
  end
end
