# frozen_string_literal: true
FactoryBot.define do
  factory :groups_group, class: "Groups::Group" do
    association :organization, factory: :organizations_organization

    sequence(:name) { |n| "Group#{n}" }

    trait :default do
      name { "default" }
    end
  end
end

# == Schema Information
#
# Table name: groups_groups
#
#  id              :uuid             not null, primary key
#  deleted_at      :datetime
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_groups_groups_on_deleted_at       (deleted_at)
#  index_groups_groups_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
