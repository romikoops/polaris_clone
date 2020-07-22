# frozen_string_literal: true

module Legacy
  class Trip < ApplicationRecord
    self.table_name = 'trips'
    has_many :layovers, dependent: :destroy
    belongs_to :tenant_vehicle
    belongs_to :itinerary

    scope :for_dates, (lambda do |start_date, end_date|
      where(Arel::Nodes::InfixOperation.new(
              'OVERLAPS',
              Arel::Nodes::SqlLiteral.new("(#{arel_table[:start_date].name}, #{arel_table[:end_date].name})"),
              Arel::Nodes::SqlLiteral.new("(DATE '#{start_date}', DATE '#{end_date}')")
            ))
    end)

    scope :lastday_today, -> { where('closing_date > ?', Date.current) }

    def vehicle
      tenant_vehicle.vehicle
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
