# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe Nexus, type: :model do
    describe ".valid locode" do
      let(:nexus) { FactoryBot.build(:legacy_nexus, locode: "GOO1") }

      it "builds an invalid object with an invalid locode" do
        expect(nexus).not_to be_valid
      end
    end
  end
end
