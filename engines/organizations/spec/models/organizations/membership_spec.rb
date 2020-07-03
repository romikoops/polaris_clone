require 'rails_helper'

module Organizations
  RSpec.describe Organizations::Membership, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
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
