# frozen_string_literal: true

require "rails_helper"

RSpec.describe Legacy::HubDecorator do
  let(:hub) { FactoryBot.create(:gothenburg_hub, hub_type: hub_type) }
  let(:hub_type) { "ocean" }
  let(:scope) { {append_hub_suffix: false} }

  describe ".decorate" do
    let(:decorated_hub) { described_class.new(hub, context: {scope: scope}) }
    let(:legacy_json) { decorated_hub.legacy_json }

    context "without suffix" do
      it "returns the legacy json format" do
        aggregate_failures do
          expect(legacy_json.dig("nexus").keys).to match_array(%w[id name])
          expect(legacy_json.dig("address", "country").keys).to match_array(%w[name])
        end
      end

      it "returns the name unadorned" do
        expect(decorated_hub.name).to eq(hub.name)
      end
    end

    context "with suffix" do
      let(:scope) { {append_hub_suffix: true} }

      context "when ocean" do
        it "returns the name adorned with correct suffix" do
          expect(decorated_hub.name).to eq([hub.name, Legacy::Hub::MOT_HUB_NAME[hub_type]].join(" "))
        end
      end

      context "when air" do
        let(:hub_type) { "air" }

        it "returns the name adorned with correct suffix" do
          expect(decorated_hub.name).to eq([hub.name, Legacy::Hub::MOT_HUB_NAME[hub_type]].join(" "))
        end
      end

      context "when rail" do
        let(:hub_type) { "rail" }

        it "returns the name adorned with correct suffix" do
          expect(decorated_hub.name).to eq([hub.name, Legacy::Hub::MOT_HUB_NAME[hub_type]].join(" "))
        end
      end

      context "when truck" do
        let(:hub_type) { "truck" }

        it "returns the name adorned with correct suffix" do
          expect(decorated_hub.name).to eq([hub.name, Legacy::Hub::MOT_HUB_NAME[hub_type]].join(" "))
        end
      end

      context "when custom" do
        let(:hub_type) { "truck" }
        let(:custom_suffix) { "Garage" }
        let(:scope) { {append_hub_suffix: true, hub_suffixes: {truck: custom_suffix}}.with_indifferent_access }

        it "returns the name adorned with correct suffix" do
          expect(decorated_hub.name).to eq([hub.name, custom_suffix].join(" "))
        end
      end
    end
  end
end
