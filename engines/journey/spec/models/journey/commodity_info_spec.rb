require "rails_helper"

module Journey
  RSpec.describe CommodityInfo, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_commodity_info)).to be_valid
    end

    context "with invalid IMO Class" do
      it "is invalid" do
        expect(FactoryBot.build(:journey_commodity_info, imo_class: "AABB")).not_to be_valid
      end
    end
  end
end
