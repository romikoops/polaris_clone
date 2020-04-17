# frozen_string_literal: true

module Tenants
  class Tenant < ApplicationRecord
    include ::Tenants::Legacy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :legacy, class_name: 'Legacy::Tenant', optional: true
    has_one :scope, as: :target, class_name: 'Tenants::Scope'
    has_one :theme, class_name: 'Tenants::Theme'
    has_many :users
    has_many :margins, as: :applicable
    has_many :memberships, as: :member
    has_many :groups, through: :memberships, as: :member
    has_many :domains

    validates :slug, presence: true, uniqueness: true

    accepts_nested_attributes_for :theme

    has_paper_trail

    def default_domain
      domains.find_by(default: true)&.domain
    end

    def subdomain
      slug
    end
    deprecate :subdomain, deprecator: ActiveSupport::Deprecation.new('', Rails.application.railtie_name)
  end
end

# == Schema Information
#
# Table name: tenants_tenants
#
#  id         :uuid             not null, primary key
#  subdomain  :string
#  legacy_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string
#
