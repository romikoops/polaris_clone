# frozen_string_literal: true

module Tracker
  class Interaction < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    default_scope { where(organization_id: ::Organizations.current_id) }

    validates :name, presence: true, uniqueness: { scope: :organization_id }
  end
end

# == Schema Information
#
# Table name: tracker_interactions
#
#  id              :uuid             not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_interactions_on_organization_id          (organization_id,name) UNIQUE
#  index_tracker_interactions_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
