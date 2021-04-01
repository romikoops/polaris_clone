# frozen_string_literal: true

module Organizations
  class IntegrationToken < ApplicationRecord
    scope :active, -> { where("expires_at > NOW() OR expires_at IS NULL") }

    belongs_to :organization

    validates_presence_of :token, :scope
    validates_format_of :scope, with: /\A([a-z]+\.)*[a-z]+\z/
  end
end

# == Schema Information
#
# Table name: organizations_integration_tokens
#
#  id              :uuid             not null, primary key
#  description     :string
#  expires_at      :datetime
#  scope           :string
#  token           :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_organizations_integration_tokens_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
