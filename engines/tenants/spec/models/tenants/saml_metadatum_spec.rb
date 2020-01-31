require 'rails_helper'

module Tenants
  RSpec.describe SamlMetadatum, type: :model do
    it 'is valid' do
      expect(FactoryBot.build(:tenants_saml_metadatum)).to be_valid
    end
  end
end
