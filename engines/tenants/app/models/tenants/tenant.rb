# frozen_string_literal: true

module Tenants
  class Tenant < ApplicationRecord
    include ::Tenants::Legacy

    belongs_to :legacy, class_name: '::Tenant', optional: true
    has_many :users

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
