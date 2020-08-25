# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pricings::ManipulatorResult do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:original) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:instance) { FactoryBot.build(:manipulator_result, original: original, result: original.as_json) }

  context "with freight rates" do
    let(:itinerary) { FactoryBot.create(:legacy_itinerary, :default, mode_of_transport: "rail") }
    let(:original) { FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary) }

    describe ".validity" do
      it "returns the correct date range" do
        expect(instance.validity).to eq(original.validity)
      end
    end

    describe ".cbm_ratio" do
      it "returns the correct ratio" do
        expect(instance.cbm_ratio).to eq(original.wm_rate)
      end
    end

    describe ".fees" do
      it "returns the fees in json form" do
        expect(instance.fees).to eq(original.as_json.dig("data"))
      end
    end

    describe ".section" do
      it "returns the correct section" do
        expect(instance.section).to eq("cargo")
      end
    end

    describe ".direction" do
      it "returns the correct direction" do
        expect(instance.direction).to be_nil
      end
    end

    describe ".cargo_class" do
      it "returns the correct cargo_class" do
        expect(instance.cargo_class).to eq(original.cargo_class)
      end
    end

    describe ".load_type" do
      it "returns the correct load_type" do
        expect(instance.load_type).to eq(original.load_type)
      end
    end

    describe ".itinerary_id" do
      it "returns the correct itinerary_id" do
        expect(instance.itinerary_id).to eq(original.itinerary_id)
      end
    end

    describe ".mot" do
      it "returns the correct mot" do
        expect(instance.send(:mot)).to eq "rail"
      end
    end

    describe ".type" do
      it "returns the correct type" do
        expect(instance.send(:type)).to eq "Pricings::Pricing"
      end
    end
  end

  context "with trucking rates" do
    let(:hub) { FactoryBot.create(:legacy_hub, hub_type: "air") }
    let(:load_meterage) { {ratio: 100, height_limit: 1.5, hard_limit: true} }
    let(:original) do
      FactoryBot.create(:trucking_trucking,
        organization: organization,
        hub: hub,
        load_meterage: load_meterage)
    end

    describe ".load_meterage_ratio" do
      it "returns the correct ratio" do
        expect(instance.load_meterage_ratio).to eq(original.load_meterage["ratio"])
      end
    end

    describe ".load_meterage_limit" do
      it "returns the correct limit" do
        expect(instance.load_meterage_limit).to eq(original.load_meterage["height_limit"])
      end
    end

    describe ".load_meterage_hard_limit" do
      it "returns the correct hard_limit" do
        expect(instance.load_meterage_hard_limit).to eq(original.load_meterage["hard_limit"])
      end
    end

    describe ".load_meterage_type" do
      it "returns the correct type" do
        expect(instance.load_meterage_type).to eq("height_limit")
      end
    end

    describe ".section" do
      it "returns the correct section" do
        expect(instance.section).to eq("trucking_pre")
      end
    end

    describe ".direction" do
      it "returns the correct direction" do
        expect(instance.direction).to eq("export")
      end
    end

    describe ".truck_type" do
      it "returns the correct truck_type" do
        expect(instance.truck_type).to eq("default")
      end
    end

    describe ".hub_id" do
      it "returns the correct hub_id" do
        expect(instance.hub_id).to eq(original.hub_id)
      end
    end

    describe ".mot" do
      it "returns the correct mot" do
        expect(instance.send(:mot)).to eq "air"
      end
    end

    describe ".type" do
      it "returns the correct type" do
        expect(instance.send(:type)).to eq "Trucking::Trucking"
      end
    end
  end

  context "with local charges" do
    let(:original) { FactoryBot.create(:legacy_local_charge, organization: organization, mode_of_transport: "air") }

    describe ".section" do
      it "returns the correct section" do
        expect(instance.section).to eq("export")
      end
    end

    describe ".cargo_class" do
      it "returns the correct cargo_class" do
        expect(instance.cargo_class).to eq("lcl")
      end
    end

    describe ".load_type" do
      it "returns the correct load_type" do
        expect(instance.load_type).to eq("cargo_item")
      end
    end

    describe ".direction" do
      it "returns the correct direction" do
        expect(instance.direction).to eq("export")
      end
    end

    describe ".hub_id" do
      it "returns the correct hub_id" do
        expect(instance.hub_id).to eq(original.hub_id)
      end
    end

    describe ".mot" do
      it "returns the correct mot" do
        expect(instance.send(:mot)).to eq "air"
      end
    end

    describe ".cbm_ratio" do
      it "returns the correct ratio" do
        expect(instance.cbm_ratio).to eq(167)
      end
    end

    describe ".type" do
      it "returns the correct type" do
        expect(instance.send(:type)).to eq "Legacy::LocalCharge"
      end
    end
  end
end
