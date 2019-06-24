# frozen_string_literal: true

module Tenants
  class Group < ApplicationRecord
    include PgSearch

    has_one :scope, as: :target, class_name: 'Tenants::Scope'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :memberships, class_name: 'Tenants::Membership'
    has_many :group_memberships, class_name: 'Tenants::Membership', as: :member
    has_many :groups, through: :group_memberships, as: :member

    pg_search_scope :search, against: %i(name), using: {
      tsearch: { prefix: true }
    }

    def members
      memberships.map do |m|
        member = m.member
        member.respond_to?(:legacy) ? member.legacy : member
      end
    end

    def member_count
      memberships.size
    end

    def margins
      Pricings::Margin.where(applicable: self)
    end

    def margin_count
      margins.size
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
