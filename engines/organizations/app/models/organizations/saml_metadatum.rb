module Organizations
  class SamlMetadatum < ApplicationRecord
    belongs_to :organization
    validates :content, presence: true
  end
end

# == Schema Information
#
# Table name: organizations_saml_metadata
#
#  id              :uuid             not null, primary key
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_organizations_saml_metadata_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
