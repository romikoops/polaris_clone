# frozen_string_literal: true

module Trucking
  class HubAvailability < ApplicationRecord
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :type_availability, class_name: 'Trucking::TypeAvailability'

    delegate :truck_type, to: :type_availability
  end
end

# == Schema Information
#
# Table name: trucking_hub_availabilities
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  hub_id               :integer
#  sandbox_id           :uuid
#  type_availability_id :uuid
#
# Indexes
#
#  index_trucking_hub_availabilities_on_hub_id                (hub_id)
#  index_trucking_hub_availabilities_on_sandbox_id            (sandbox_id)
#  index_trucking_hub_availabilities_on_type_availability_id  (type_availability_id)
#
