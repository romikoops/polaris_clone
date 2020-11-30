# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::LocationSearcher do
  describe ".get" do
    it "returns the constantized service" do
      expect(described_class.get(identifier: "city")).to eq(Locations::Searchers::City)
    end

    it "returns the default service" do
      expect(described_class.get(identifier: nil)).to eq(Locations::Searchers::Default)
    end

    it "returns the default service when identifier is unknown" do
      expect(described_class.get(identifier: "blue")).to eq(Locations::Searchers::Default)
    end
  end
end
