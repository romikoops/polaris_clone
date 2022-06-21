# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::DateExpander do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:period) { Range.new(Time.zone.today, 2.weeks.from_now.to_date) }
  let(:date_expander) { described_class.new(period: period, dates: dates) }

  before { Organizations.current_id = organization.id }

  describe "#expand" do
    let(:expanded_frame) { date_expander.expand(input: input_frame) }
    let(:dates) { input_frame[%w[effective_date expiration_date]] }

    context "when there are dates extending before the given date row, but not covering it entirely" do
      let(:input_frame) do
        Rover::DataFrame.new([
          { "effective_date" => 1.week.ago.to_date, "expiration_date" => 1.week.from_now.to_date }
        ])
      end

      expected_data = [
        {
          "effective_date" => Time.zone.today,
          "expiration_date" => 1.week.from_now.to_date,
          "original_effective_date" => 1.week.ago.to_date,
          "original_expiration_date" => 1.week.from_now.to_date
        }
      ]

      it "returns the lookup frame with two periods, split based on the expiry of the dates in the frame" do
        expect(expanded_frame.to_a).to match_array(expected_data)
      end
    end

    context "when there are dates extending past the given date row, but not covering it entirely" do
      let(:input_frame) do
        Rover::DataFrame.new([
          { "effective_date" => 1.week.from_now.to_date, "expiration_date" => 3.weeks.from_now.to_date }
        ])
      end

      expected_data = [
        { "effective_date" => 1.week.from_now.to_date, "expiration_date" => 2.weeks.from_now.to_date, "original_effective_date" => 1.week.from_now.to_date, "original_expiration_date" => 3.weeks.from_now.to_date }
      ]

      it "returns the lookup frame with two periods, split based on the expiry of the dates in the frame" do
        expect(expanded_frame.to_a).to match_array(expected_data)
      end
    end

    context "when there are multiple overlapping dates" do
      let(:input_frame) do
        Rover::DataFrame.new([
          { "effective_date" => 1.week.ago.to_date, "expiration_date" => 2.days.from_now.to_date },
          { "effective_date" => 2.weeks.ago.to_date, "expiration_date" => 10.days.from_now.to_date },
          { "effective_date" => 1.week.from_now.to_date, "expiration_date" => 3.weeks.from_now.to_date }
        ])
      end

      expected_data = [
        { "effective_date" => Time.zone.today,
          "expiration_date" => 2.days.from_now.to_date,
          "original_effective_date" => 1.week.ago.to_date,
          "original_expiration_date" => 2.days.from_now.to_date },
        { "effective_date" => Time.zone.today,
          "expiration_date" => 2.days.from_now.to_date,
          "original_effective_date" => 2.weeks.ago.to_date,
          "original_expiration_date" => 10.days.from_now.to_date },
        { "effective_date" => 2.days.from_now.to_date,
          "expiration_date" => 1.week.from_now.to_date,
          "original_effective_date" => 2.weeks.ago.to_date,
          "original_expiration_date" => 10.days.from_now.to_date },
        { "effective_date" => 1.week.from_now.to_date,
          "expiration_date" => 10.days.from_now.to_date,
          "original_effective_date" => 2.weeks.ago.to_date,
          "original_expiration_date" => 10.days.from_now.to_date },
        { "effective_date" => 1.week.from_now.to_date,
          "expiration_date" => 10.days.from_now.to_date,
          "original_effective_date" => 1.week.from_now.to_date,
          "original_expiration_date" => 3.weeks.from_now.to_date },
        { "effective_date" => 10.days.from_now.to_date,
          "expiration_date" => 2.weeks.from_now.to_date,
          "original_effective_date" => 1.week.from_now.to_date,
          "original_expiration_date" => 3.weeks.from_now.to_date }
      ]

      it "returns the lookup frame with three periods, split based on the expiry of the dates in the frame" do
        expect(expanded_frame.to_a).to match_array(expected_data)
      end
    end
  end
end
