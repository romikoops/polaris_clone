# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe RateBasis, type: :model do
    describe ".get_internal_key" do
      it "returns the input rate basis when one doesnt exist" do
        target = RateBasis.get_internal_key("PER_SHIPMENT")
        expect(target).to eq("PER_SHIPMENT")
      end

      it "returns the existsing rate basis if it exists" do
        RateBasis.create(external_code: "PER_MBL", internal_code: "PER_SHIPMENT")
        target = RateBasis.get_internal_key("PER_MBL")
        expect(target).to eq("PER_SHIPMENT")
      end
    end
  end
end

# == Schema Information
#
# Table name: rate_bases
#
#  id            :bigint           not null, primary key
#  external_code :string
#  internal_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
