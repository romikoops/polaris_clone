# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidityService do
  let(:trips) do
    (1...10).map do |num|
      create(:trip,
             load_type: 'cargo_item',
             start_date: Date.today + (num * 2).days,
             end_date: Date.today + ((num * 2) + 30).days)
    end
  end
  let(:schedules) do
    trips.map { |trip| Legacy::Schedule.from_trip(trip) }.sort_by(&:etd)
  end
  let(:booking_date) { 2.days.from_now }

  describe '.parse_schedules' do
    it 'returns the correct dates for V.A.T.O.S import' do
      validity_service = described_class.new(logic: 'vatos', schedules: schedules, direction: 'import', booking_date: nil)
      expect(validity_service.start_date.beginning_of_minute).to eq(schedules.first.etd.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(schedules.last.etd.beginning_of_minute)
    end

    it 'returns the correct dates for V.A.T.O.A import' do
      validity_service = described_class.new(logic: 'vatoa', schedules: schedules, direction: 'import', booking_date: nil)
      expect(validity_service.start_date.beginning_of_minute).to eq(schedules.first.eta.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(schedules.last.eta.beginning_of_minute)
    end

    it 'returns the correct dates for V.A.T.O.B import' do
      validity_service = described_class.new(logic: 'vatob', schedules: schedules, direction: 'import', booking_date: booking_date)
      expect(validity_service.start_date.beginning_of_minute).to eq(booking_date.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(booking_date.beginning_of_minute)
    end

    it 'returns the correct dates for V.A.T.O.S export' do
      validity_service = described_class.new(logic: 'vatos', schedules: schedules, direction: 'export', booking_date: nil)
      expect(validity_service.start_date.beginning_of_minute).to eq(schedules.first.etd.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(schedules.last.etd.beginning_of_minute)
    end

    it 'returns the correct dates for V.A.T.O.A export' do
      validity_service = described_class.new(logic: 'vatoa', schedules: schedules, direction: 'export', booking_date: nil)
      expect(validity_service.start_date.beginning_of_minute).to eq(schedules.first.etd.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(schedules.last.etd.beginning_of_minute)
    end

    it 'returns the correct dates for V.A.T.O.B export' do
      validity_service = described_class.new(logic: 'vatob', schedules: schedules, direction: 'export', booking_date: booking_date)
      expect(validity_service.start_date.beginning_of_minute).to eq(booking_date.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(booking_date.beginning_of_minute)
    end

    it 'returns the default dates for no schedules V.A.T.O.S import' do
      validity_service = described_class.new(logic: 'vatos', schedules: [], direction: 'import', booking_date: booking_date)
      expect(validity_service.start_date.beginning_of_minute).to eq(5.days.from_now.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(25.days.from_now.beginning_of_minute)
    end

    it 'returns the default dates for no schedules V.A.T.O.A import' do
      validity_service = described_class.new(logic: 'vatoa', schedules: [], direction: 'import', booking_date: booking_date)
      expect(validity_service.start_date.beginning_of_minute).to eq(5.days.from_now.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(25.days.from_now.beginning_of_minute)
    end

    it 'returns the default dates for no schedules V.A.T.O.S export' do
      validity_service = described_class.new(logic: 'vatos', schedules: [], direction: 'export', booking_date: booking_date)
      expect(validity_service.start_date.beginning_of_minute).to eq(5.days.from_now.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(25.days.from_now.beginning_of_minute)
    end

    it 'returns the default dates for no schedules V.A.T.O.A export' do
      validity_service = described_class.new(logic: 'vatoa', schedules: [], direction: 'export', booking_date: booking_date)
      expect(validity_service.start_date.beginning_of_minute).to eq(5.days.from_now.beginning_of_minute)
      expect(validity_service.end_date.beginning_of_minute).to eq(25.days.from_now.beginning_of_minute)
    end
  end
end
