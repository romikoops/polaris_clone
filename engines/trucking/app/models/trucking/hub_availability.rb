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
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  hub_id               :integer
#  sandbox_id           :uuid
#  type_availability_id :uuid
#
# Indexes
#
#  index_trucking_hub_availabilities_on_sandbox_id  (sandbox_id)
#
