module Pricings
  class LocationGroup < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :nexus, class_name: "Legacy::Nexus"

    validates_presence_of :name
  end
end

# == Schema Information
#
# Table name: pricings_location_groups
#
#  id              :uuid             not null, primary key
#  name            :citext           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  nexus_id        :bigint
#  organization_id :uuid
#
# Indexes
#
#  index_organization_location_groups                 (nexus_id,name,organization_id) UNIQUE
#  index_pricings_location_groups_on_nexus_id         (nexus_id)
#  index_pricings_location_groups_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (nexus_id => nexuses.id) ON DELETE => cascade
#  fk_rails_...  (organization_id => organizations_organizations.id) ON DELETE => cascade
#
