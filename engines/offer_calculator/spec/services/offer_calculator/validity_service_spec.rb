# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::ValidityService do
  let(:trips) do
    (1...10).map do |num|
      FactoryBot.create(:legacy_trip,
                        load_type: 'cargo_item',
                        start_date: Date.today + (num * 2).days,
                        end_date: Date.today + ((num * 2) + 30).days)
    end
  end
  let(:schedules) do
    trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) }.sort_by(&:etd)
  end
  let(:booking_date) { 2.days.from_now }

  describe '.parse_schedules' do
    it 'returns the correct dates for V.A.T.O.S import' do
      validity_service = described_class.new(logic: 'vatos', schedules: schedules, direction: 'import', booking_date: nil)
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedules.first.etd.to_date)
        expect(validity_service.end_date).to eq(schedules.last.etd.to_date)
      end
    end

    it 'returns the correct dates for V.A.T.O.A import' do
      validity_service = described_class.new(logic: 'vatoa', schedules: schedules, direction: 'import', booking_date: nil)
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedules.first.eta.to_date)
        expect(validity_service.end_date).to eq(schedules.last.eta.to_date)
      end
    end

    it 'returns the correct dates for V.A.T.O.B import' do
      validity_service = described_class.new(logic: 'vatob', schedules: schedules, direction: 'import', booking_date: booking_date)
      aggregate_failures do
        expect(validity_service.start_date).to eq(booking_date.to_date)
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end

    it 'returns the correct dates for V.A.T.O.S export' do
      validity_service = described_class.new(logic: 'vatos', schedules: schedules, direction: 'export', booking_date: nil)
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedules.first.etd.to_date)
        expect(validity_service.end_date).to eq(schedules.last.etd.to_date)
      end
    end

    it 'returns the correct dates for V.A.T.O.A export' do
      validity_service = described_class.new(logic: 'vatoa', schedules: schedules, direction: 'export', booking_date: nil)
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedules.first.etd.to_date)
        expect(validity_service.end_date).to eq(schedules.last.etd.to_date)
      end
    end

    it 'returns the correct dates for V.A.T.O.B export' do
      validity_service = described_class.new(logic: 'vatob', schedules: schedules, direction: 'export', booking_date: booking_date)
      aggregate_failures do
        expect(validity_service.start_date).to eq(booking_date.to_date)
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end

    it 'returns the default dates for no schedules V.A.T.O.S import' do
      validity_service = described_class.new(logic: 'vatos', schedules: [], direction: 'import', booking_date: booking_date)
      aggregate_failures do
        expect(validity_service.start_date).to eq(5.days.from_now.to_date)
        expect(validity_service.end_date).to eq(25.days.from_now.to_date)
      end
    end

    it 'returns the default dates for no schedules V.A.T.O.A import' do
      validity_service = described_class.new(logic: 'vatoa', schedules: [], direction: 'import', booking_date: booking_date)
      aggregate_failures do
        expect(validity_service.start_date).to eq(5.days.from_now.to_date)
        expect(validity_service.end_date).to eq(25.days.from_now.to_date)
      end
    end

    it 'returns the default dates for no schedules V.A.T.O.S export' do
      validity_service = described_class.new(logic: 'vatos', schedules: [], direction: 'export', booking_date: booking_date)
      aggregate_failures do
        expect(validity_service.start_date).to eq(5.days.from_now.to_date)
        expect(validity_service.end_date).to eq(25.days.from_now.to_date)
      end
    end

    it 'returns the default dates for no schedules V.A.T.O.A export' do
      validity_service = described_class.new(logic: 'vatoa', schedules: [], direction: 'export', booking_date: booking_date)
      aggregate_failures do
        expect(validity_service.start_date).to eq(5.days.from_now.to_date)
        expect(validity_service.end_date).to eq(25.days.from_now.to_date)
      end
    end
  end

  describe '.parse_schedule' do
    let(:schedule) { schedules.first }

    it 'returns the correct dates for one schedule V.A.T.O.S export' do
      validity_service = described_class.new(logic: 'vatos', schedules: [], direction: '', booking_date: booking_date)
      validity_service.parse_schedule(schedule: schedule, direction: 'export')
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.etd.to_date)
        expect(validity_service.end_date).to eq(schedule.etd.to_date + 1.day)
      end
    end

    it 'returns the correct dates for one schedule V.A.T.O.A export' do
      validity_service = described_class.new(logic: 'vatoa', schedules: [], direction: '', booking_date: booking_date)
      validity_service.parse_schedule(schedule: schedule, direction: 'export')
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.etd.to_date)
        expect(validity_service.end_date).to eq(schedule.etd.to_date + 1.day)
      end
    end

    it 'returns the correct dates for one schedule V.A.T.O.B export' do
      validity_service = described_class.new(logic: 'vatob', schedules: [], direction: '', booking_date: booking_date)
      validity_service.parse_schedule(schedule: schedule, direction: 'export')
      aggregate_failures do
        expect(validity_service.start_date).to eq(booking_date.to_date)
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end

    it 'returns the correct dates for one schedule V.A.T.O.S import' do
      validity_service = described_class.new(logic: 'vatos', schedules: [], direction: '', booking_date: booking_date)
      validity_service.parse_schedule(schedule: schedule, direction: 'import')
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.etd.to_date)
        expect(validity_service.end_date).to eq(schedule.etd.to_date + 1.day)
      end
    end

    it 'returns the correct dates for one schedule V.A.T.O.A import' do
      validity_service = described_class.new(logic: 'vatoa', schedules: [], direction: '', booking_date: booking_date)
      validity_service.parse_schedule(schedule: schedule, direction: 'import')
      aggregate_failures do
        expect(validity_service.start_date).to eq(schedule.eta.to_date)
        expect(validity_service.end_date).to eq(schedule.eta.to_date + 1.day)
      end
    end

    it 'returns the correct dates for one schedule V.A.T.O.B import' do
      validity_service = described_class.new(logic: 'vatob', schedules: [], direction: '', booking_date: booking_date)
      validity_service.parse_schedule(schedule: schedule, direction: 'import')
      aggregate_failures do
        expect(validity_service.start_date).to eq(booking_date.to_date)
        expect(validity_service.end_date).to eq(booking_date.to_date + 1.day)
      end
    end
  end
end
