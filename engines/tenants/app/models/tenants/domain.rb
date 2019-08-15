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
#  tenant_id  :uuid
#  domain     :string
#  default    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
