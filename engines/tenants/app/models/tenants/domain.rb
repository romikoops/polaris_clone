# frozen_string_literal: true


module Tenants
  class Domain < ApplicationRecord
    belongs_to :organization, class_name: 'Organizations::Organization'

    validates :domain, uniqueness: true
    validates :default, inclusion: { in: [true, false] }, uniqueness: { scope: :organization_id, if: :default? }
  end
end

# == Schema Information
#
# Table name: tenants_domains
#
#  id         :uuid             not null, primary key
#  default    :boolean
#  domain     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_domains_on_tenant_id  (tenant_id)
#
