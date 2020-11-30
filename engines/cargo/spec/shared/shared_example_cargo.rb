# frozen_string_literal: true

require "rails_helper"

module Cargo
  RSpec.describe "a Cargo", type: :model do
    RSpec.shared_examples "aggregated cargo" do
      describe ".area" do
        it "return the correct area" do
          expected_area = 1.3 / Specification::DEFAULT_HEIGHT * 2
          expect(subject.area).to eq(Measured::Area.new(expected_area, :m2))
        end
      end

      describe ".stowage_factor" do
        it "return the correct stowage_factor" do
          expected_stowage_factor = (1.3 / (3000 / 1000.0)).round(6)
          expect(subject.stowage_factor).to eq(Measured::StowageFactor.new(expected_stowage_factor, "m3/t"))
        end
      end

      describe ".stackable" do
        it "return the correct stackable" do
          expect(subject.stackable?).to eq(true)
        end
      end
    end

    RSpec.shared_examples "multiple lcl units" do
      describe ".area" do
        it "return the correct area" do
          expected_area = (1.20 * 0.8) * 2 * 5
          expect(subject.area).to eq(Measured::Area.new(expected_area, :m2))
        end
      end

      describe ".stackable" do
        it "return the correct stackable" do
          expect(subject.stackable?).to eq(false)
        end
      end

      describe ".lcl" do
        it "return the correct lcl" do
          expect(subject.lcl?).to eq(true)
        end
      end

      describe ".consolidated" do
        it "return the correct consolidated" do
          expect(subject.consolidated?).to eq(false)
        end
      end

      describe ".stowage_factor" do
        it "return the correct stowage_factor" do
          expected_stowage_factor = ((1.20 * 0.8 * 1.40 * 2 * 5) / (3000 * 2 * 5 / 1000.0)).round(6)
          expect(subject.stowage_factor).to eq(Measured::StowageFactor.new(expected_stowage_factor, "m3/t"))
        end
      end

      describe ".quantity" do
        it "return the quantities sum of the units" do
          expect(subject.quantity).to eq(subject.units.sum(:quantity))
        end
      end
    end

    RSpec.shared_examples "updatable weight and volume" do
      it "reflects the updates on the entire cargo" do
        expect(subject.weight).to eq(Measured::Weight.new(6000, :kg))
        expect(subject.volume).to eq(Measured::Volume.new(2.688, :m3))
        subject.units.first.update(width_value: 1, weight_value: 1.5)
        expect(subject.weight).to eq(Measured::Weight.new(3, :kg))
        expect(subject.volume).to eq(Measured::Volume.new(2.24, :m3))
      end
    end
  end
end
