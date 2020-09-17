require "rails_helper"

module Groups
  RSpec.describe Membership, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
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
