# frozen_string_literal: true

module Users
  class Membership < ApplicationRecord
    belongs_to :user, class_name: "Users::User"
    belongs_to :organization, class_name: "Organizations::Organization"

    enum role: {owner: 1, admin: 2, user: 3}
  end
end

# == Schema Information
#
# Table name: users_memberships
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
#  index_users_memberships_on_organization_id              (organization_id)
#  index_users_memberships_on_role                         (role)
#  index_users_memberships_on_user_id                      (user_id)
#  index_users_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
