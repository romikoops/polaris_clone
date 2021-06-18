# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe LineItemSet, type: :model do
    before { allow(Journey::ImcReference).to receive(:new).and_return(instance_double("Journey::ImcReference", reference: "1234")) }

    it "builds a valid object" do
      expect(FactoryBot.build(:journey_line_item_set)).to be_valid
    end

    it "sets the reference number" do
      expect(FactoryBot.create(:journey_line_item_set, reference: nil).reference).to eq("1234")
    end
  end
end
