# frozen_string_literal: true


module Tenants
  class Domain < ApplicationRecord
    belongs_to :tenant

    validates :domain, uniqueness: true
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
