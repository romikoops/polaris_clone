# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Base do
  let(:organization) { FactoryBot.build(:organizations_organization) }

  describe "#find_hub_by_name_or_locode_with_info" do
    let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
    let(:mode_of_transport) { hub.hub_type }
    let(:name) { hub.name }
    let(:country) { hub.country.name }
    let(:locode) { hub.hub_code }

    context "name & country provided" do
      it "finds a hub" do
        allow(subject).to receive(:organization).and_return(organization)
        hub_with_info = subject.find_hub_by_name_or_locode_with_info(
          name: name,
          country: country,
          mot: mode_of_transport,
          locode: nil
        )
        expect(hub_with_info).to eq({hub: hub, found_by_info: [name, country].join(", ")})
      end

      it "does not find a hub" do
        allow(subject).to receive(:organization).and_return(organization)
        hub_with_info = subject.find_hub_by_name_or_locode_with_info(
          name: "Not-existent",
          country: nil,
          mot: mode_of_transport,
          locode: nil
        )
        expect(hub_with_info).to eq({hub: nil, found_by_info: "Not-existent"})
      end
    end

    context "locode provided" do
      it "finds a hub" do
        allow(subject).to receive(:organization).and_return(organization)
        hub_with_info = subject.find_hub_by_name_or_locode_with_info(
          name: nil,
          country: nil,
          mot: mode_of_transport,
          locode: locode
        )
        expect(hub_with_info).to eq({hub: hub, found_by_info: locode})
      end

      it "does not find a hub" do
        allow(subject).to receive(:organization).and_return(organization)
        hub_with_info = subject.find_hub_by_name_or_locode_with_info(
          name: nil,
          country: nil,
          mot: mode_of_transport,
          locode: "XXXXX"
        )
        expect(hub_with_info).to eq({hub: nil, found_by_info: "XXXXX"})
      end
    end
  end
end
