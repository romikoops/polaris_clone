# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe Routing, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_routing)).to be_valid }

      context "when origin and destination locations are the same" do
        let(:location) { FactoryBot.create(:ledger_location) }
        let(:routing) { FactoryBot.build(:ledger_routing, origin_location: location, destination_location: location) }

        it "is invalid with proper error text", :aggregate_failures do
          expect(routing).to be_invalid
          expect(routing.errors[:origin_location]).to eq(["can not be the same as the destination location"])
        end
      end
    end
  end
end
