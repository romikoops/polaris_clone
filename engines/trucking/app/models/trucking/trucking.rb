# frozen_string_literal: true

module Trucking
  class Trucking < ApplicationRecord
    belongs_to :rate, class_name: 'Trucking::Rate'
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :location, class_name: 'Trucking::Location'
    validates :rate_id, :hub_id, :location_id, presence: true
  end
end

# == Schema Information
#
# Table name: trucking_truckings
#
#  id          :uuid             not null, primary key
#  hub_id      :integer
#  location_id :uuid
#  rate_id     :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
