# frozen_string_literal: true

module Tenants
  class Group < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :memberships, class_name: 'Tenants::Membership'
    has_many :groups, through: :memberships
    include PgSearch

    pg_search_scope :search, against: %i(name), using: {
      tsearch: { prefix: true }
    }

    def members
      memberships.map do |m|
        member = m.member
        member&.legacy if member.is_a?(Tenants::User)
      end
    end

    def groups
      ::Tenants::Group.where(id: memberships.pluck(:group_id))
    end

    def member_list
      memberships.map(&:for_list_json)
    end

    def member_count
      memberships.size
    end

    def margins
      Margins::Margin.where(applicable: self)
    end

    def margins_list
      margins.map(&:for_list_json)
    end

    def margin_count
      margins.size
    end

    def for_index_json(options = {})
      new_options = options.reverse_merge(
        methods: %i(member_count margin_count)
      )
      as_json(new_options)
    end

    def for_show_json(options = {})
      new_options = options.reverse_merge(
        methods: %i(member_list margins_list)
      )
      as_json(new_options)
    end
  end
end

# == Schema Information
#
# Table name: tenants_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  tenant_id  :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
