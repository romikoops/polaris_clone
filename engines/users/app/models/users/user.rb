# frozen_string_literal: true

module Users
  class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true
    validates :name, presence: true
    validates :google_id, presence: true

    authenticates_with_sorcery!
  end
end

# == Schema Information
#
# Table name: users_users
#
#  id                         :uuid             not null, primary key
#  email                      :string
#  name                       :string
#  google_id                  :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  last_login_at              :datetime
#  last_logout_at             :datetime
#  last_activity_at           :datetime
#  last_login_from_ip_address :string
#
