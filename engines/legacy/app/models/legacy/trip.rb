# frozen_string_literal: true

module Legacy
  class Trip < ApplicationRecord
    self.table_name = 'trips'
    has_many :layovers, dependent: :destroy
    belongs_to :tenant_vehicle
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :itinerary
    scope :for_dates, (lambda do |start_date, end_date|
      where(Arel::Nodes::InfixOperation.new(
              'OVERLAPS',
              Arel::Nodes::SqlLiteral.new("(#{arel_table[:start_date].name}, #{arel_table[:end_date].name})"),
              Arel::Nodes::SqlLiteral.new("(DATE '#{start_date}', DATE '#{end_date}')")
            ))
    end)
  end
end

# == Schema Information
#
# Table name: trips
#
#  id                :bigint(8)        not null, primary key
#  itinerary_id      :integer
#  start_date        :datetime
#  end_date          :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  voyage_code       :string
#  vessel            :string
#  tenant_vehicle_id :integer
#  closing_date      :datetime
#  load_type         :string
#  sandbox_id        :uuid
#
