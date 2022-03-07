# frozen_string_literal: true

require "rails_helper"

module Carta
  RSpec.describe Result do
    let(:result) { FactoryBot.create(:carta_result) }

    describe "#nexus?" do
      it "returns true when the type is 'locode'" do
        expect(result.nexus?).to eq(true)
      end

      context "when the type is 'address'" do
        let(:result) { FactoryBot.create(:carta_result, :address) }

        it "returns true when the type is 'address'" do
          expect(result.nexus?).to eq(false)
        end
      end
    end

    describe "#city" do
      it "returns the address attribute when the type is 'locode'" do
        expect(result.city).to eq(result.address)
      end

      context "when the type is 'address'" do
        let(:result) { FactoryBot.create(:carta_result, :address) }

        it "returns the locality attributes when the type is 'address'" do
          expect(result.city).to eq(result.locality)
        end
      end
    end
  end
end
