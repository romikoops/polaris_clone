# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::ValidityService do
  let(:trips) do
    (1...3).map do |num|
      FactoryBot.create(:legacy_trip,
        load_type: "cargo_item",
        start_date: Time.zone.today + (num * 2).days,
        end_date: Time.zone.today + ((num * 2) + 30).days)
    end
  end
  let(:schedules) do
    trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) }.sort_by(&:etd)
  end
  let(:booking_date) { 2.days.from_now }
  let(:validity_service) do
    described_class.new(logic: logic, schedules: schedules, direction: direction, booking_date: booking_date)
  end

  describe "#start_date" do
    context "when configured for V.A.T.O.S import" do
      let(:logic) { "vatos" }
      let(:direction) { "import" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.S import" do
        expect(validity_service.start_date).to eq(schedules.first.etd.to_date)
      end
    end

    context "when configured for V.A.T.O.A import" do
      let(:logic) { "vatoa" }
      let(:direction) { "import" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.A import" do
        expect(validity_service.start_date).to eq(schedules.first.eta.to_date)
      end
    end

    context "when configured for V.A.T.O.B import" do
      let(:logic) { "vatob" }
      let(:direction) { "import" }

      it "returns the correct date for V.A.T.O.B import" do
        expect(validity_service.start_date).to eq(booking_date.to_date)
      end
    end

    context "when configured for V.A.T.O.S export" do
      let(:logic) { "vatos" }
      let(:direction) { "export" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.S export" do
        expect(validity_service.start_date).to eq(schedules.first.etd.to_date)
      end
    end

    context "when configured for V.A.T.O.A export" do
      let(:logic) { "vatoa" }
      let(:direction) { "export" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.A export" do
        expect(validity_service.start_date).to eq(schedules.first.etd.to_date)
      end
    end

    context "when configured for V.A.T.O.B export" do
      let(:logic) { "vatob" }
      let(:direction) { "export" }

      it "returns the correct date for V.A.T.O.B export" do
        expect(validity_service.start_date).to eq(booking_date.to_date)
      end
    end

    context "with no schedules V.A.T.O.S import" do
      let(:logic) { "vatos" }
      let(:schedules) { [] }
      let(:direction) { "import" }

      it "returns the default date for no schedules V.A.T.O.S import" do
        expect(validity_service.start_date).to eq(described_class::START_BUFFER.days.from_now.to_date)
      end
    end

    context "with no schedules V.A.T.O.A import" do
      let(:logic) { "vatoa" }
      let(:schedules) { [] }
      let(:direction) { "import" }

      it "returns the default date for no schedules V.A.T.O.A import" do
        expect(validity_service.start_date).to eq(described_class::START_BUFFER.days.from_now.to_date)
      end
    end

    context "with no schedules V.A.T.O.S export" do
      let(:logic) { "vatos" }
      let(:schedules) { [] }
      let(:direction) { "export" }

      it "returns the default date for no schedules V.A.T.O.S export" do
        expect(validity_service.start_date).to eq(described_class::START_BUFFER.days.from_now.to_date)
      end
    end

    context "with no schedules V.A.T.O.A export" do
      let(:logic) { "vatoa" }
      let(:schedules) { [] }
      let(:direction) { "export" }

      it "returns the default date for no schedules V.A.T.O.A export" do
        expect(validity_service.start_date).to eq(described_class::START_BUFFER.days.from_now.to_date)
      end
    end

    context "with unknown logic export" do
      let(:logic) { "aaa" }
      let(:direction) { "export" }

      it "returns the default date for unknown logic export" do
        expect(validity_service.start_date).to eq(described_class::START_BUFFER.days.from_now.to_date)
      end
    end
  end

  describe "#end_date" do
    context "when configured for V.A.T.O.S import" do
      let(:logic) { "vatos" }
      let(:direction) { "import" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.S import" do
        expect(validity_service.end_date).to eq(schedules.last.etd.to_date)
      end
    end

    context "when configured for V.A.T.O.A import" do
      let(:logic) { "vatoa" }
      let(:direction) { "import" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.A import" do
        expect(validity_service.end_date).to eq(schedules.last.eta.to_date)
      end
    end

    context "when configured for V.A.T.O.B import" do
      let(:logic) { "vatob" }
      let(:direction) { "import" }

      it "returns the correct date for V.A.T.O.B import" do
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end

    context "when configured for V.A.T.O.S export" do
      let(:logic) { "vatos" }
      let(:direction) { "export" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.S export" do
        expect(validity_service.end_date).to eq(schedules.last.etd.to_date)
      end
    end

    context "when configured for V.A.T.O.A export" do
      let(:logic) { "vatoa" }
      let(:direction) { "export" }
      let(:booking_date) { nil }

      it "returns the correct date for V.A.T.O.A export" do
        expect(validity_service.end_date).to eq(schedules.last.etd.to_date)
      end
    end

    context "when configured for V.A.T.O.B export" do
      let(:logic) { "vatob" }
      let(:direction) { "export" }

      it "returns the correct date for V.A.T.O.B export" do
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end

    context "with no schedules V.A.T.O.S import" do
      let(:logic) { "vatos" }
      let(:schedules) { [] }
      let(:direction) { "import" }

      it "returns the default date for no schedules V.A.T.O.S import" do
        expect(validity_service.end_date).to eq(described_class::END_BUFFER.days.from_now.to_date)
      end
    end

    context "with no schedules V.A.T.O.A import" do
      let(:logic) { "vatoa" }
      let(:schedules) { [] }
      let(:direction) { "import" }

      it "returns the default date for no schedules V.A.T.O.A import" do
        expect(validity_service.end_date).to eq(described_class::END_BUFFER.days.from_now.to_date)
      end
    end

    context "with no schedules V.A.T.O.S export" do
      let(:logic) { "vatos" }
      let(:schedules) { [] }
      let(:direction) { "export" }

      it "returns the default date for no schedules V.A.T.O.S export" do
        expect(validity_service.end_date).to eq(described_class::END_BUFFER.days.from_now.to_date)
      end
    end

    context "with no schedules V.A.T.O.A export" do
      let(:logic) { "vatoa" }
      let(:schedules) { [] }
      let(:direction) { "export" }

      it "returns the default date for no schedules V.A.T.O.A export" do
        expect(validity_service.end_date).to eq(described_class::END_BUFFER.days.from_now.to_date)
      end
    end

    context "with unknown logic export" do
      let(:logic) { "aaa" }
      let(:direction) { "export" }

      it "returns the default date for unknown logic export" do
        expect(validity_service.end_date).to eq(described_class::END_BUFFER.days.from_now.to_date)
      end
    end
  end

  describe "#parse_schedule" do
    let(:schedule) { schedules.first }
    let(:validity_service) do
      described_class.new(logic: logic, schedules: [], direction: "", booking_date: booking_date).tap do |service|
        service.parse_schedule(schedule: schedule, direction: direction)
      end
    end

    context "with V.A.T.O.S export logic" do
      let(:direction) { "export" }
      let(:logic) { "vatos" }

      it "returns the correct dates for one schedule V.A.T.O.S export", :aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.etd.to_date)
        expect(validity_service.end_date).to eq(schedule.etd.to_date + 1.day)
      end
    end

    context "with V.A.T.O.A export logic" do
      let(:direction) { "export" }
      let(:logic) { "vatoa" }

      it "returns the correct dates for one schedule V.A.T.O.A export", :aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.etd.to_date)
        expect(validity_service.end_date).to eq(schedule.etd.to_date + 1.day)
      end
    end

    context "with V.A.T.O.B export logic" do
      let(:direction) { "export" }
      let(:logic) { "vatob" }

      it "returns the correct dates for one schedule V.A.T.O.B export", :aggregate_failures do
        expect(validity_service.start_date).to eq(booking_date.to_date)
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end

    context "with V.A.T.O.S import logic" do
      let(:direction) { "import" }
      let(:logic) { "vatos" }

      it "returns the correct dates for one schedule V.A.T.O.S import", :aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.etd.to_date)
        expect(validity_service.end_date).to eq(schedule.etd.to_date + 1.day)
      end
    end

    context "with V.A.T.O.A import logic" do
      let(:direction) { "import" }
      let(:logic) { "vatoa" }

      it "returns the correct dates for one schedule V.A.T.O.A import", :aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.eta.to_date)
        expect(validity_service.end_date).to eq(schedule.eta.to_date + 1.day)
      end
    end

    context "with V.A.T.O.B import logic" do
      let(:direction) { "import" }
      let(:logic) { "vatob" }

      it "returns the correct dates for one schedule V.A.T.O.B import", :aggregate_failures do
        expect(validity_service.start_date).to eq(booking_date.to_date)
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end
  end

  describe "#period" do
    let(:schedule) { schedules.first }
    let(:validity_service) do
      described_class.new(logic: logic, schedules: [], direction: "", booking_date: booking_date).tap do |service|
        service.parse_schedule(schedule: schedule, direction: direction)
      end
    end

    context "when configured for V.A.T.O.S export" do
      let(:logic) { "vatos" }
      let(:direction) { "export" }

      it "returns the correct period for one schedule V.A.T.O.S export" do
        expect(validity_service.period).to eq(Range.new(schedule.etd.to_date, schedule.etd.to_date + 1.day, exclude_end: true))
      end
    end

    context "when configured for V.A.T.O.A export" do
      let(:logic) { "vatoa" }
      let(:direction) { "export" }

      it "returns the correct period for one schedule V.A.T.O.A export" do
        expect(validity_service.period).to eq(Range.new(schedule.etd.to_date, schedule.etd.to_date + 1.day, exclude_end: true))
      end
    end

    context "when configured for V.A.T.O.B export" do
      let(:logic) { "vatob" }
      let(:direction) { "export" }

      it "returns the correct period for one schedule V.A.T.O.B export" do
        expect(validity_service.period).to eq(Range.new(booking_date.to_date, booking_date.to_date + 1.day, exclude_end: true))
      end
    end

    context "when configured for V.A.T.O.S import" do
      let(:logic) { "vatos" }
      let(:direction) { "import" }

      it "returns the correct period for one schedule V.A.T.O.S import" do
        expect(validity_service.period).to eq(Range.new(schedule.etd.to_date, schedule.etd.to_date + 1.day, exclude_end: true))
      end
    end

    context "when configured for V.A.T.O.A import" do
      let(:logic) { "vatoa" }
      let(:direction) { "import" }

      it "returns the correct period for one schedule V.A.T.O.A import" do
        expect(validity_service.period).to eq(Range.new(schedule.eta.to_date, schedule.eta.to_date + 1.day, exclude_end: true))
      end
    end

    context "when configured for V.A.T.O.B import" do
      let(:logic) { "vatob" }
      let(:direction) { "import" }

      it "returns the correct period for one schedule V.A.T.O.B import" do
        expect(validity_service.period).to eq(Range.new(booking_date.to_date, booking_date.to_date + 1.day, exclude_end: true))
      end
    end
  end
end
