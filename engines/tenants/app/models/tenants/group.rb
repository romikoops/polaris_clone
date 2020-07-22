# frozen_string_literal: true

module Tenants
  class Group < ApplicationRecord
    include PgSearch::Model

    has_one :scope, as: :target, class_name: 'Tenants::Scope'
    belongs_to :organization, class_name: 'Organizations::Organization'
    has_many :memberships, class_name: 'Groups::Membership', dependent: :destroy
    has_many :group_memberships, class_name: 'Groups::Membership', as: :member
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
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_groups_on_sandbox_id  (sandbox_id)
#  index_tenants_groups_on_tenant_id   (tenant_id)
#
