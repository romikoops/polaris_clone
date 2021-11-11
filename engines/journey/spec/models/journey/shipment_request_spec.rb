# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe ShipmentRequest, type: :model do
    it "creates a valid object" do
      expect(FactoryBot.create(:journey_shipment_request)).to be_valid
    end

    describe "#file_binary" do
      it "returns the attached file as a blob" do
        expect(FactoryBot.create(:journey_shipment_request).file_binary.bytesize).to eq(
          File.read(File.expand_path("../../../factories/fixtures/example_pdf.pdf", __dir__)).bytesize
        )
      end
    end
  end
end
