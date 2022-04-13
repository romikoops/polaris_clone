# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Support::DateLimiter do
  let(:result) { described_class.new(frame: frame, start_date: Time.zone.today, end_date: 1.week.from_now.to_date).perform }
  let(:frame) { Rover::DataFrame.new(date_rows) }
  let(:date_rows) do
    [{ "effective_date" => 1.week.ago.to_date, "expiration_date" => 1.month.from_now.to_date, "code" => "puf", "rate" => "10" }]
  end

  describe "#perform" do
    it "returns the frame with the effective and expiration dates limited by the given period", :aggregate_failures do
      expect(result["effective_date"]).to eq([Time.zone.today])
      expect(result["expiration_date"]).to eq([1.week.from_now.to_date])
    end

    context "when the dates lie within the period" do
      let(:date_rows) do
        [{
          "effective_date" => Time.zone.tomorrow.to_date,
          "expiration_date" => 3.days.from_now.to_date,
          "code" => "puf",
          "rate" => "10"
        }]
      end

      it "returns the frame as is" do
        expect(result).to eq(frame)
      end
    end

    context "when the dates lie outside the period" do
      let(:date_rows) do
        [{
          "effective_date" => 3.weeks.from_now.to_date,
          "expiration_date" => 7.weeks.from_now.to_date,
          "code" => "puf",
          "rate" => "10"
        }]
      end

      it "returns the frame with the effective and expiration dates limited by the given period", :aggregate_failures do
        expect(result["effective_date"]).to eq([Time.zone.today])
        expect(result["expiration_date"]).to eq([1.week.from_now.to_date])
      end
    end
  end
end
