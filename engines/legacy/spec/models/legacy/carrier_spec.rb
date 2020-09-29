require "rails_helper"

module Legacy
  RSpec.describe Carrier, type: :model do
    let!(:carrier) { FactoryBot.create(:legacy_carrier, code: "123") }

    context "with valid data" do
      it "Creates a valid carrier" do
        expect(carrier).to be_valid
      end
    end

    context "with duplicate data" do
      let(:duplicate) { FactoryBot.create(:legacy_carrier, code: "123") }

      it "violates the uniqueness constraint" do
        expect { duplicate }.to raise_error { ActiveRecord::RecordInvalid }
      end
    end
  end
end
