# frozen_string_literal: true

module Tenants
  class Membership < ApplicationRecord
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :member, polymorphic: true
    belongs_to :group
    validates_uniqueness_of :member_type, scope: %i(member_id priority)
    before_validation :set_priority

    default_scope { order(:priority) }

    def member_name
      case member.class.to_s
      when 'Tenants::User'
        member&.legacy&.full_name
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
      when 'Tenants::Group'
        'group'
      when 'Tenants::Company'
        'company'
      end
    end

    private

    def set_priority
      existing_memberships = Tenants::Membership
                             .where(member: member)
                             .order(priority: :desc)

      return if existing_memberships.empty?

      self.priority = existing_memberships.first.priority + 1
    end
  end
end

# == Schema Information
#
# Table name: tenants_memberships
#
#  id          :uuid             not null, primary key
#  member_type :string
#  member_id   :uuid
#  group_id    :uuid
#  priority    :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sandbox_id  :uuid
#
