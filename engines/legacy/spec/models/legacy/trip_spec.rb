# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Trip, type: :model do
    let(:start_date) { DateTime.now }
    let(:end_date) { DateTime.now + 5.days }
    let!(:trip) { FactoryBot.create(:legacy_trip, start_date: start_date, end_date: end_date) }

    describe '.for_dates' do
      it 'returns the Rgeo WKT point of the trip' do
        expect(described_class.for_dates(start_date - 1.day, end_date + 2.days)).to eq([trip])
      end
    end
  end
end
