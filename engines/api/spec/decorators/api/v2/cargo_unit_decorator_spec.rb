# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::CargoUnitDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:query) { FactoryBot.build(:journey_query, organization: organization) }
  let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, query: query) }
  let(:decorated_cargo_unit) do
    described_class.new(cargo_unit, context: { scope: Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access })
  end

  describe ".weight" do
    it "returns weight as a Float", :aggregate_failures do
      expect(decorated_cargo_unit.weight).to eq(cargo_unit.weight_value.to_f)
      expect(decorated_cargo_unit.weight).to be_a(Float)
    end
  end

  describe ".length" do
    it "returns length as a Float", :aggregate_failures do
      expect(decorated_cargo_unit.length).to eq((cargo_unit.length_value * 100.0).to_f)
      expect(decorated_cargo_unit.length).to be_a(Float)
    end
  end

  describe ".width" do
    it "returns width as a Float", :aggregate_failures do
      expect(decorated_cargo_unit.width).to eq((cargo_unit.width_value * 100.0).to_f)
      expect(decorated_cargo_unit.width).to be_a(Float)
    end
  end

  describe ".height" do
    it "returns height as a Float", :aggregate_failures do
      expect(decorated_cargo_unit.height).to eq((cargo_unit.height_value * 100.0).to_f)
      expect(decorated_cargo_unit.height).to be_a(Float)
    end
  end

  describe ".volume" do
    it "returns volume as a Float", :aggregate_failures do
      expect(decorated_cargo_unit.volume).to eq(cargo_unit.volume_value.to_f)
      expect(decorated_cargo_unit.volume).to be_a(Float)
    end
  end
end
