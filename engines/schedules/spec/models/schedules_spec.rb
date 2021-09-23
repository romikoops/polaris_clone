# frozen_string_literal: true

require "rails_helper"

module Schedules
  RSpec.describe Schedule, type: :model do
    let(:schedules_schedule) do
      FactoryBot.build(:schedules_schedule)
    end

    let(:organization) { schedules_schedule.organization }
    let(:schedules_schedule1) { FactoryBot.build(:schedules_schedule, organization: organization) }

    it "builds a valid schedule" do
      expect(schedules_schedule).to be_valid
    end

    it "is invalid without a vessel name" do
      expect(FactoryBot.build(:schedules_schedule, vessel_name: nil)).not_to be_valid
    end

    it "is invalid without a origin" do
      expect(FactoryBot.build(:schedules_schedule, origin: nil)).not_to be_valid
    end

    it "is invalid without a destination" do
      expect(FactoryBot.build(:schedules_schedule, destination: nil)).not_to be_valid
    end

    it "is invalid without a destination_arrival" do
      expect(FactoryBot.build(:schedules_schedule, destination_arrival: nil)).not_to be_valid
    end

    describe "testing dates" do
      context "when destination arrival time is before the departure" do
        let(:schedules_schedule2) { FactoryBot.build(:schedules_schedule, destination_arrival: schedules_schedule.origin_departure - 1.day) }

        it "raises ArgumentError" do
          expect { schedules_schedule2.save! }.to(raise_error { ArgumentError })
        end
      end

      context "when closing date is after the departure date" do
        let(:schedules_schedule2) { FactoryBot.build(:schedules_schedule, closing_date: schedules_schedule.origin_departure + 1.day) }

        it "raises ArgumentError" do
          expect { schedules_schedule2.save! }.to(raise_error { ArgumentError })
        end
      end

      context "when closing date same departure date" do
        let(:schedules_schedule2) { FactoryBot.build(:schedules_schedule, closing_date: schedules_schedule.origin_departure) }

        it "raises ArgumentError" do
          expect { schedules_schedule2.save! }.not_to(raise_error { ArgumentError })
        end
      end
    end
  end
end
