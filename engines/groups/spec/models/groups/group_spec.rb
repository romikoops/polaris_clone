require 'rails_helper'

module Groups
  RSpec.describe Group, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
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
