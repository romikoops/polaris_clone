# frozen_string_literal: true

module Ledger
  class Routing < ApplicationRecord
    belongs_to :origin_location, class_name: "Ledger::Location"
    belongs_to :destination_location, class_name: "Ledger::Location"

    validates :origin_location, uniqueness: { scope: :destination_location_id }
    validate :origin_and_destination_difference

    private

    def origin_and_destination_difference
      return if origin_location_id.blank? || destination_location_id.blank?
      return if origin_location_id != destination_location_id

      errors.add(:origin_location, "can not be the same as the destination location")
    end
  end
end

# == Schema Information
#
# Table name: ledger_routings
#
#  id                      :uuid             not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  destination_location_id :uuid             not null
#  origin_location_id      :uuid             not null
#
# Indexes
#
#  index_ledger_routings_on_destination_location_id  (destination_location_id)
#  index_ledger_routings_on_origin_location_id       (origin_location_id)
#
