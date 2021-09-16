# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::HubDecorator do
  let(:hub) { FactoryBot.create(:gothenburg_hub, hub_type: hub_type) }
  let(:hub_type) { "ocean" }
  let(:scope) { { append_hub_suffix: false } }
  let(:decorated_hub) { described_class.new(hub, context: { scope: scope }) }

  describe "#legacy_json" do
    let(:legacy_json) { decorated_hub.legacy_json }

    it "returns the legacy json format", :aggregate_failures do
      expect(legacy_json["nexus"].keys).to match_array(%w[id name])
      expect(legacy_json.dig("address", "country").keys).to match_array(%w[name])
    end
  end

  describe "#legacy_index_json" do
    it "returns the legacy json format with earliest expiry", :aggregate_failures do
      expect(decorated_hub.legacy_index_json.keys).to match_array(hub.attributes.keys + ["nexus", "address", :earliest_expiration])
    end
  end

  describe "#select_option" do
    it "returns the select option format", :aggregate_failures do
      expect(decorated_hub.select_option).to eq({ label: hub.name, value: decorated_hub.legacy_index_json })
    end
  end

  describe "#name" do
    shared_examples_for "returning the properly formatted name" do
      it "returns the name adorned with correct suffix" do
        expect(decorated_hub.name).to eq(expected_name)
      end
    end

    context "without suffix" do
      let(:expected_name) { hub.name }

      it_behaves_like "returning the properly formatted name"
    end

    context "with suffix" do
      let(:scope) { { append_hub_suffix: true } }
      let(:expected_name) { [hub.name, suffix].join(" ") }

      context "when ocean" do
        let(:suffix) { "Port" }

        it_behaves_like "returning the properly formatted name"
      end

      context "when air" do
        let(:suffix) { "Airport" }
        let(:hub_type) { "air" }

        it_behaves_like "returning the properly formatted name"
      end

      context "when rail" do
        let(:suffix) { "Railway Station" }
        let(:hub_type) { "rail" }

        it_behaves_like "returning the properly formatted name"
      end

      context "when truck" do
        let(:suffix) { "Depot" }
        let(:hub_type) { "truck" }

        it_behaves_like "returning the properly formatted name"
      end

      context "when custom" do
        let(:hub_type) { "truck" }
        let(:custom_suffix) { "Garage" }
        let(:scope) { { append_hub_suffix: true, hub_suffixes: { truck: custom_suffix } }.with_indifferent_access }
        let(:expected_name) { [hub.name, custom_suffix].join(" ") }

        it_behaves_like "returning the properly formatted name"
      end

      context "with terminal" do
        let(:suffix) { "Port" }
        let(:hub) { FactoryBot.create(:gothenburg_hub, terminal: "A1", hub_type: hub_type) }
        let(:expected_name) { "#{[hub.name, suffix].join(' ')} (#{hub.terminal})" }

        it_behaves_like "returning the properly formatted name"
      end

      context "when name ends with suffix already" do
        let(:suffix) { "Port" }
        let(:hub) { FactoryBot.create(:gothenburg_hub, name: "Gothenburg #{suffix}", hub_type: hub_type) }
        let(:expected_name) { hub.name }

        it_behaves_like "returning the properly formatted name"
      end
    end
  end
end
