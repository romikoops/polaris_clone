require 'rails_helper'

module Organizations
  RSpec.describe Scope, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
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
