# frozen_string_literal: true

module Tenants
  class Membership < ApplicationRecord
    belongs_to :member, polymorphic: true
    belongs_to :group

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

    def for_list_json(options = {})
      new_options = options.reverse_merge(
        methods: %i(member_name member_type member_email original_member_id)
      )
      as_json(new_options)
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
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  priority    :integer          default(0)
#
