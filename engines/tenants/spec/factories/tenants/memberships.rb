# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_membership, class: 'Tenants::Membership' do
    association :group, factory: :tenants_group
    association :member, factory: :tenants_users
    trait :user do
      association :member, factory: :tenants_users
    end
    trait :company do
      association :member, factory: :tenants_companies
    end
  end
end

# == Schema Information
#
# Table name: tenants_memberships
#
#  id          :uuid             not null, primary key
#  member_type :string
#  priority    :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :uuid
#  member_id   :uuid
#  sandbox_id  :uuid
#
# Indexes
#
#  index_tenants_memberships_on_member_type_and_member_id  (member_type,member_id)
#  index_tenants_memberships_on_sandbox_id                 (sandbox_id)
#
