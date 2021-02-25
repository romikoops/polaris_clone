# frozen_string_literal: true

module Organizations
  class Organization < ApplicationRecord
    has_many :domains, dependent: :destroy, inverse_of: :organization

    has_one :theme, dependent: :destroy, inverse_of: :organization
    accepts_nested_attributes_for :theme

    has_one :scope, as: :target, class_name: "Organizations::Scope", inverse_of: :target
    accepts_nested_attributes_for :scope

    validates :slug, presence: true, uniqueness: true, format: {with: /[a-z-]{1,63}/}

    has_paper_trail

    class << self
      def current_id=(id)
        RequestStore.store[:organization_id] = id
      end

      def current_id
        RequestStore.store[:organization_id]
      end

      def current
        find_by(id: current_id)
      end
    end
  end
end

# == Schema Information
#
# Table name: organizations_organizations
#
#  id         :uuid             not null, primary key
#  live       :boolean          default(FALSE)
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_organizations_on_slug  (slug) UNIQUE
#
