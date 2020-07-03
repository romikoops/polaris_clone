# frozen_string_literal: true

module Users
  class Authentication < ApplicationRecord
    belongs_to :user
  end
end

# == Schema Information
#
# Table name: users_authentications
#
#  id         :uuid             not null, primary key
#  provider   :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_users_authentications_on_user_id  (user_id)
#  provider_uid_on_users_authentications   (provider,uid)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
