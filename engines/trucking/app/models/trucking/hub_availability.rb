module Trucking
  class HubAvailability < ApplicationRecord
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :type_availability, class_name: 'Trucking::TypeAvailability'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  end
end

# == Schema Information
#
# Table name: trucking_hub_availabilities
#
#  id                   :uuid             not null, primary key
#  hub_id               :integer
#  type_availability_id :uuid
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  sandbox_id           :uuid
#
