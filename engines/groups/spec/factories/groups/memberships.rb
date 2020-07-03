FactoryBot.define do
  factory :groups_membership, class: "Groups::Membership" do
    priority { 1 }
    group { nil }

    trait :user do
      association :member, factory: [:organizations_user, :with_profile]
    end
  end
end

# == Schema Information
#
# Table name: groups_memberships
#
#  id          :uuid             not null, primary key
#  member_type :string
#  priority    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :uuid
#  member_id   :uuid
#
# Indexes
#
#  index_groups_memberships_on_group_id                   (group_id)
#  index_groups_memberships_on_member_type_and_member_id  (member_type,member_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups_groups.id)
#
