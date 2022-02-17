# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe QueryCalculation, type: :model do
    it "builds a valid Journey::QueryCalculation" do
      expect(FactoryBot.build(:journey_query_calculation)).to be_valid
    end

    describe "#status" do
      it "contains the correct status values" do
        statuses = %w[queued running completed failed]
        statuses.each do |item|
          expect(described_class.statuses[item]).to eq(item)
        end
      end

      it "raises an error when the status is blank" do
        expect { FactoryBot.create(:journey_query_calculation, status: "") }.to raise_error(/Status can't be blank/)
      end

      it "raises an error when the status is invalid" do
        expect { FactoryBot.create(:journey_query_calculation, status: "chillin") }.to raise_error(/'chillin' is not a valid status/)
      end
    end
  end
end
