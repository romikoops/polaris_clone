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
#  tenant_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
