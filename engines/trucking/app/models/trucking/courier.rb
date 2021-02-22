# frozen_string_literal: true
module Trucking
  class Courier < ApplicationRecord
    has_many :rates, class_name: "Trucking::Rate"
    belongs_to :organization, class_name: "Organizations::Organization"
  end
end

# == Schema Information
#
# Table name: trucking_couriers
#
#  id              :uuid             not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_trucking_couriers_on_organization_id  (organization_id)
#  index_trucking_couriers_on_sandbox_id       (sandbox_id)
#  index_trucking_couriers_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
