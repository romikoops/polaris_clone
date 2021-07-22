# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Base do
  let(:base_class) { described_class.new }
  let(:organization) { FactoryBot.build(:organizations_organization) }

  before { allow(base_class).to receive(:organization).and_return(organization) }

  describe "#find_hub_by_name_or_locode_with_info" do
    let(:hub) { FactoryBot.create(:gothenburg_hub, organization: organization) }
    let(:mode_of_transport) { hub.hub_type }
    let(:name) { hub.name }
    let(:country) { hub.country.name }
    let(:locode) { hub.hub_code }
    let(:hub_with_info) { base_class.find_hub_by_name_or_locode_with_info(args) }

    context "when name & country provided and the hub is found" do
      let(:args) do
        {
          name: name,
          country: country,
          mot: mode_of_transport,
          locode: nil
        }
      end

      it "finds a hub" do
        expect(hub_with_info).to eq({ hub: hub, found_by_info: [name, country].join(", ") })
      end
    end

    context "when name & country provided and the hub is not found" do
      let(:args) do
        {
          name: "Not-existent",
          country: nil,
          mot: mode_of_transport,
          locode: nil
        }
      end

      it "does not find a hub" do
        expect(hub_with_info).to eq({ hub: nil, found_by_info: "Not-existent" })
      end
    end

    context "when locode provided and hub is found" do
      let(:args) do
        {
          name: nil,
          country: nil,
          mot: mode_of_transport,
          locode: locode
        }
      end

      it "finds a hub" do
        expect(hub_with_info).to eq({ hub: hub, found_by_info: locode })
      end
    end

    context "when locode provided and hub is not found" do
      let(:args) do
        {
          name: nil,
          country: nil,
          mot: mode_of_transport,
          locode: "XXXXX"
        }
      end

      it "does not find a hub" do
        expect(hub_with_info).to eq({ hub: nil, found_by_info: "XXXXX" })
      end
    end

    context "when name & country exist for different locodeand the hub is found" do
      let(:args) do
        {
          name: name,
          country: country,
          mot: mode_of_transport,
          locode: hub.locode
        }
      end

      before do
        FactoryBot.create(:legacy_hub,
          name: hub.name,
          hub_type: hub.hub_type,
          organization: organization,
          nexus: FactoryBot.build(:legacy_nexus, locode: "XEGOT", organization: organization))
      end

      it "finds a hub" do
        expect(hub_with_info).to eq({ hub: hub, found_by_info: [name, country, locode].join(", ") })
      end
    end
  end
end
