# frozen_string_literal: true

FactoryBot.define do
  factory :organizations_scope, class: "Organizations::Scope" do
    content { {} }

    for_organization

    trait :for_organization do
      target { association(:organizations_organization, scope: instance) }
    end
  end
end

# == Schema Information
#
# Table name: organizations_scopes
#
#  id          :uuid             not null, primary key
#  content     :jsonb
#  target_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  target_id   :uuid
#
# Indexes
#
#  index_organizations_scopes_on_target_type_and_target_id  (target_type,target_id)
#
