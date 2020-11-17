# frozen_string_literal: true

FactoryBot.define do
  factory :organizations_organization, class: "Organizations::Organization" do
    sequence(:slug) { |n| "test_#{n}" }

    trait :with_max_dimensions do
      after(:create) do |organization, evaluator|
        FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
        FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
      end
    end
  end
end

# == Schema Information
#
# Table name: organizations_organizations
#
#  id                      :uuid             not null, primary key
#  slug                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :bigint
#  tenants_organization_id :uuid
#
# Indexes
#
#  index_organizations_organizations_on_organization_id          (organization_id)
#  index_organizations_organizations_on_slug                     (slug) UNIQUE
#  index_organizations_organizations_on_tenants_organization_id  (tenants_organization_id)
#
