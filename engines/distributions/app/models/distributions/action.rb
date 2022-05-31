# frozen_string_literal: true

module Distributions
  class Action < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :target_organization, class_name: "Organizations::Organization"
    validates_uniqueness_of :order, scope: %i[organization_id target_organization_id]
    enum action_types: {
      "add_fee" => "add_fee",
      "duplicate" => "duplicate",
      "adjust_fee" => "adjust_fee",
      "add_values" => "add_values"
    }
  end
end

# == Schema Information
#
# Table name: distributions_actions
#
#  id                     :uuid             not null, primary key
#  action_type            :enum
#  arguments              :jsonb
#  order                  :integer          default(1), not null
#  upload_schema          :string           not null
#  where                  :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organization_id        :uuid
#  target_organization_id :uuid
#
# Indexes
#
#  index_distributions_actions_on_order                   (order) UNIQUE
#  index_distributions_actions_on_organization_id         (organization_id)
#  index_distributions_actions_on_target_organization_id  (target_organization_id)
#  index_distributions_actions_on_upload_schema           (upload_schema)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id) ON DELETE => cascade
#  fk_rails_...  (target_organization_id => organizations_organizations.id) ON DELETE => cascade
#
