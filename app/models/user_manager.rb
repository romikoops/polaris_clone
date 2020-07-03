# frozen_string_literal: true

class UserManager < ApplicationRecord
end

# == Schema Information
#
# Table name: user_managers
#
#  id             :bigint           not null, primary key
#  section        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  legacy_user_id :integer
#  manager_id     :integer
#  user_id        :uuid
#
# Indexes
#
#  index_user_managers_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
