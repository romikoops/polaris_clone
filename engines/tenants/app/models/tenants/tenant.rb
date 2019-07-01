# frozen_string_literal: true

module Tenants
  class Tenant < ApplicationRecord
    include ::Tenants::Legacy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :legacy, class_name: 'Legacy::Tenant', optional: true
    has_one :scope, as: :target, class_name: 'Tenants::Scope'
    has_many :users
    has_many :margins, as: :applicable
    has_many :memberships, as: :member
    has_many :groups, through: :memberships, as: :member

    validates :subdomain, presence: true, uniqueness: true

    has_paper_trail
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
#
