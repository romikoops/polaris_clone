# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_agency, class: "Legacy::Agency" do
    name { "Agency Name" }

    association :organization, factory: :organizations_organization
    association :agency_manager, factory: :organizations_user
  end
end

# == Schema Information
#
# Table name: agencies
#
#  id                :bigint           not null, primary key
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  agency_manager_id :integer
#  organization_id   :uuid
#  tenant_id         :integer
#
# Indexes
#
#  index_agencies_on_organization_id  (organization_id)
#  index_agencies_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
