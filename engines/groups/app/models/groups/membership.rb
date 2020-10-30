# frozen_string_literal: true

module Groups
  class Membership < ApplicationRecord
    acts_as_paranoid
    default_scope { order(:priority) }

    belongs_to :member, polymorphic: true
    belongs_to :group

    # validates :member_id, uniqueness: { scope: [:group_id] }

    before_validation :set_priority

    private

    def set_priority
      priority = self.class.where(member: member).reorder(priority: :desc).pluck(:priority).first
      self.priority = (priority || 0) + 1
    end
  end
end

# == Schema Information
#
# Table name: groups_memberships
#
#  id          :uuid             not null, primary key
#  deleted_at  :datetime
#  member_type :string
#  priority    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :uuid
#  member_id   :uuid
#
# Indexes
#
#  index_groups_memberships_on_deleted_at                 (deleted_at)
#  index_groups_memberships_on_group_id                   (group_id)
#  index_groups_memberships_on_member_type_and_member_id  (member_type,member_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups_groups.id)
#
