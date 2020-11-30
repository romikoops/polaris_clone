# frozen_string_literal: true

require "rails_helper"

module Cargo
  RSpec.shared_examples "a Cargo Unit", type: :model do
    context "instance methods" do
      describe ".total_area" do
        it "return the correct area" do
          expected_area = 1.2 * 0.8 * 2
          expect(subject.total_area).to eq(Measured::Area.new(expected_area, :m2))
        end
      end

      describe ".unit_area" do
        it "return the correct area per unit" do
          expect(subject.area).to eq(Measured::Area.new(0.96, :m2))
        end
      end

      describe ".total_volume" do
        it "return the correct volume" do
          expected_volume = 1.20 * 0.8 * 1.40 * 2
          expect(subject.total_volume).to eq(Measured::Volume.new(expected_volume, :m3))
        end
      end

      describe ".stowage_factor" do
        it "return the correct stowage_factor" do
          expected_stowage_factor = ((1.20 * 0.8 * 1.40) / (3000 / 1000.0)).round(6)
          expect(subject.stowage_factor).to eq(Measured::StowageFactor.new(expected_stowage_factor, "m3/t"))
        end
      end
    end
  end
end
