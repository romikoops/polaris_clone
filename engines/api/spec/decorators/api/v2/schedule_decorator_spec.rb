# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ScheduleDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:schedule) { FactoryBot.create(:schedules_schedule, origin_departure: origin_departure, destination_arrival: destination_arrival, closing_date: closing_date) }
  let(:decorated_schedule) { described_class.new(schedule) }

  describe "#transit_time" do
    let(:closing_date) { Time.zone.today }
    let(:origin_departure) { closing_date }
    let(:destination_arrival) { origin_departure + 3.weeks }

    it "transit time to equal 3 weeks in no of days" do
      # Arrival is after 3 weeks as defined in destination_arrival
      expect(decorated_schedule.transit_time).to eq(3 * 7)
    end
  end
end
