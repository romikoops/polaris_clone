# frozen_string_literal: true

module Groups
  class Group < ApplicationRecord
    acts_as_paranoid
    include PgSearch::Model

    belongs_to :organization, class_name: "Organizations::Organization"
    has_many :memberships, dependent: :destroy

    validates :name, uniqueness: {scope: %i[organization_id]}

    pg_search_scope :search, against: %i[name], using: {
      tsearch: {prefix: true}
    }

    def members
      memberships.map(&:member)
    end
  end
end

# == Schema Information
#
# Table name: groups_groups
#
#  id               :uuid             not null, primary key
#  deleted_at       :datetime
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organization_id  :uuid
#  tenants_group_id :uuid
#
# Indexes
#
#  index_groups_groups_on_deleted_at        (deleted_at)
#  index_groups_groups_on_organization_id   (organization_id)
#  index_groups_groups_on_tenants_group_id  (tenants_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
