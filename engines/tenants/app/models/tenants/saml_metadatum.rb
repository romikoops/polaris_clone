# frozen_string_literal: true

module Tenants
  class SamlMetadatum < ApplicationRecord
    belongs_to :tenant
    validates :content, presence: true
  end
end

# == Schema Information
#
# Table name: tenants_saml_metadata
#
#  id         :uuid             not null, primary key
#  content    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_saml_metadata_on_tenant_id  (tenant_id)
#
