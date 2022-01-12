# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe RequestForQuotation, type: :model do
    let(:request_for_quotations) { FactoryBot.build(:request_for_quotation) }

    it "is valid with valid attributes" do
      expect(request_for_quotations).to be_valid
    end

    it "raises `ActiveRecord::RecordInvalid` if full_name is not present" do
      request_for_quotations.full_name = nil
      expect { request_for_quotations.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "raises `ActiveRecord::RecordInvalid` if email is not present" do
      request_for_quotations.email = nil
      expect { request_for_quotations.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "raises `ActiveRecord::RecordInvalid` if phone_number is not present" do
      request_for_quotations.phone = nil
      expect { request_for_quotations.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context "with invalid email" do
      before { request_for_quotations.email = "invalid email" }

      it "raises `ActiveRecord::RecordInvalid` if email is not valid" do
        expect { request_for_quotations.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "returns error with valid message" do
        request_for_quotations.validate
        expect(request_for_quotations.errors[:email]).to include("invalid email format")
      end
    end
  end
end
