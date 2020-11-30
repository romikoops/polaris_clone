# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe Trip, type: :model do
    let(:start_date) { DateTime.now }
    let(:end_date) { DateTime.now + 5.days }
    let!(:trip) { FactoryBot.create(:legacy_trip, start_date: start_date, end_date: end_date) }

    describe ".for_dates" do
      it "returns the Rgeo WKT point of the trip" do
        expect(described_class.for_dates(start_date - 1.day, end_date + 2.days)).to eq([trip])
      end
    end
  end
end

# == Schema Information
#
# Table name: trips
#
#  id                :bigint           not null, primary key
#  closing_date      :datetime
#  end_date          :datetime
#  load_type         :string
#  start_date        :datetime
#  vessel            :string
#  voyage_code       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  itinerary_id      :integer
#  sandbox_id        :uuid
#  tenant_vehicle_id :integer
#
# Indexes
#
#  index_trips_on_closing_date       (closing_date)
#  index_trips_on_itinerary_id       (itinerary_id)
#  index_trips_on_sandbox_id         (sandbox_id)
#  index_trips_on_tenant_vehicle_id  (tenant_vehicle_id)
#
