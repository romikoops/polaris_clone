# frozen_string_literal: true

FactoryBot.define do
  factory :organizations_membership, class: 'Organizations::Membership' do
    role { :user }

    association :user, factory: :organizations_user
    association :organization, factory: :organizations_organization
  end
end

# == Schema Information
#
# Table name: organizations_members
#
#  id              :uuid             not null, primary key
#  role            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  user_id         :uuid
#
# Indexes
#
#  index_organizations_members_on_organization_id              (organization_id)
#  index_organizations_members_on_role                         (role)
#  index_organizations_members_on_user_id                      (user_id)
#  index_organizations_members_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
