require 'rails_helper'

module Tenants
  RSpec.describe SamlMetadatum, type: :model do
    it 'is valid' do
      expect(FactoryBot.build(:tenants_saml_metadatum)).to be_valid
    end
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
