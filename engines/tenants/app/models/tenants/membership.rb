# frozen_string_literal: true

module Tenants
  class Membership < ApplicationRecord
    belongs_to :member, polymorphic: true
    belongs_to :group
    validates_uniqueness_of :member_type, scope: %i(member_id priority)
    before_validation :set_priority

    default_scope { order(:priority) }

    def member_name
      case member.class.to_s
      when 'Tenants::User'
        Profiles::ProfileService.fetch(user_id: member.id).full_name
      else
        member&.name
      end
    end

    def member_email
      case member.class.to_s
      when 'Tenants::User'
        member&.legacy&.email
      when 'Tenants::Company'
        member.email
      end
    end

    def original_member_id
      case member.class.to_s
      when 'Tenants::User'
        member&.legacy_id
      else
        member_id
      end
    end

    def human_type
      case member.class.to_s
      when 'Tenants::User'
        'client'
      when 'Groups::Group'
        'group'
      when 'Tenants::Company'
        'company'
      end
    end

    private

    def set_priority
      existing_memberships = Groups::Membership
                             .where(member: member)
                             .reorder(priority: :desc)
      priority = existing_memberships.empty? ? 0 : existing_memberships.first.priority + 1

      self.priority = priority
    end
  end
end

# == Schema Information
#
# Table name: tenants_memberships
#
#  id          :uuid             not null, primary key
#  member_type :string
#  priority    :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :uuid
#  member_id   :uuid
#  sandbox_id  :uuid
#
# Indexes
#
#  index_tenants_memberships_on_member_type_and_member_id  (member_type,member_id)
#  index_tenants_memberships_on_sandbox_id                 (sandbox_id)
#
