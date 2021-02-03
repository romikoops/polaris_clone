# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::ResultDecorator do
  include_context "journey_pdf_setup"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) {
    FactoryBot.create(:users_client, organization: organization)
  }
  let(:chargeable_weight_view) { "volume" }
  let(:scope_content) {
    {"show_chargeable_weight" => true, "chargeable_weight_view" => chargeable_weight_view}
  }
  let(:scope) { OrganizationManager::ScopeService.new(target: user, organization: organization).fetch }
  let(:klass) { described_class.decorate(result, context: {scope: scope}) }
  let(:desired_line_items) { result.line_item_sets.first.line_items }

  before do
    Draper::ViewContext.controller = Pdf::ApplicationController.new

    ::Organizations.current_id = organization.id
    organization.scope.update(content: scope_content)
    allow(klass).to receive(:pre_carriage_section).and_return(pre_carriage_section)
    allow(klass).to receive(:on_carriage_section).and_return(on_carriage_section)
  end

  describe ".carriage_service_string" do
    let(:operator_string) { klass.carriage_service_string(carriage: "pre") }

    context "with default settings" do
      it "limits the quotes returned when tender ids are provided" do
        expect(operator_string).to eq("")
      end
    end

    context "with pickup carrier info settings" do
      let(:scope_content) { {"voyage_info" => {"pre_carriage_carrier" => true}} }

      it "returns the carrier info in the correct format" do
        expect(operator_string).to eq("operated by #{pre_carriage_carrier}")
      end
    end

    context "with pickup service info settings" do
      let(:scope_content) { {"voyage_info" => {"pre_carriage_service" => true}} }

      it "returns the carrier info in the correct format" do
        expect(operator_string).to eq("operated by #{pre_carriage_service}")
      end
    end

    context "with pickup carrier and service info settings" do
      let(:scope_content) { {"voyage_info" => {"pre_carriage_service" => true, "pre_carriage_carrier" => true}} }

      it "returns the carrier info in the correct format" do
        expect(operator_string).to eq("operated by #{pre_carriage_carrier}(#{pre_carriage_service})")
      end
    end
  end

  describe ".currency" do
    it "returns the tender currency" do
      expect(klass.currency).to eq(scope.dig(:default_currency))
    end
  end

  describe ".currencies" do
    it "returns the tender currencies" do
      expect(klass.currencies).to eq(desired_line_items.pluck(:total_currency).uniq)
    end
  end

  describe ".voyage_code" do
    it "returns the trip voyage_code" do
      expect(klass.voyage_code).to eq("")
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
        expect(
          klass.chargeable_weight_string(section: "cargo")
        ).to eq("<small class='chargeable_weight'> (Chargeable Volume: 1.0 m<sup>3</sup></small>")
      end
    end

    context "when trucking" do
      it "returns the chargeable weight string" do
        expect(
          klass.chargeable_weight_string(section: "trucking_pre")
        ).to eq("<small class='chargeable_weight'> (Chargeable Volume: 1.0 m<sup>3</sup></small>")
      end
    end
  end

  context "with trucking" do
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
        expect(klass.pre_carriage_service).to eq("operated by #{pre_carriage_carrier}(#{pre_carriage_service})")
      end
    end

    describe ".on_carriage_service" do
      it "returns the on carriage service" do
        expect(klass.on_carriage_service).to eq("operated by #{on_carriage_carrier}(#{on_carriage_service})")
      end
    end

    describe ".full_pickup_address" do
      it "returns the pre carriage service" do
        expect(klass.full_pickup_address).to eq("Sweden")
      end
    end

    describe ".full_delivery_address" do
      it "returns the on delivery_address" do
        expect(klass.full_delivery_address).to eq("China")
      end
    end

    describe ".has_pre_carriage?" do
      it "returns false when no carriage section exists" do
        expect(klass.has_pre_carriage?).to be_truthy
      end
    end

    describe ".has_on_carriage?" do
      it "returns false when no carriage section exists" do
        expect(klass.has_on_carriage?).to be_truthy
      end
    end
  end
end
