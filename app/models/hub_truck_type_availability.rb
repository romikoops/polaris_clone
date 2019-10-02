# frozen_string_literal: true

class HubTruckTypeAvailability < ApplicationRecord
  belongs_to :hub
  belongs_to :truck_type_availability
end

# == Schema Information
#
# Table name: hub_truck_type_availabilities
#
#  id                         :bigint           not null, primary key
#  hub_id                     :integer
#  truck_type_availability_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
