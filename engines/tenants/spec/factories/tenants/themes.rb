# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_theme, class: 'Tenants::Theme' do
    association :organization, factory: :organizations_organization
    primary_color { '#F5F5F5' }
    secondary_color { '#F8F8F8' }
    bright_primary_color { '#F6F6F6' }
    bright_secondary_color { '#F9F9F9' }
  end
end

# == Schema Information
#
# Table name: tenants_themes
#
#  id                     :uuid             not null, primary key
#  bright_primary_color   :string
#  bright_secondary_color :string
#  primary_color          :string
#  secondary_color        :string
#  welcome_text           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organization_id        :uuid
#  tenant_id              :uuid
#
# Indexes
#
#  index_tenants_themes_on_organization_id  (organization_id)
#  index_tenants_themes_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
