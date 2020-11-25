require "rails_helper"

module Journey
  RSpec.describe Result, type: :model do
    let(:result) { FactoryBot.build(:journey_result, expiration_date: expiration_date) }

    context "with a valid expiration date" do
      let(:expiration_date) { Time.zone.tomorrow }

      it "passes validation" do
        expect(result).to be_valid
      end
    end

    context "with an invalid expiration date" do
      let(:expiration_date) { Time.zone.yesterday }

      it "fails validation" do
        expect(result).not_to be_valid
      end
    end
  end
end
