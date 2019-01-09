# frozen_string_literal: true

module Users
  class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true
    validates :name, presence: true
    validates :google_id, presence: true
  end
end

# == Schema Information
#
# Table name: users_users
#
#  id         :uuid             not null, primary key
#  email      :string
#  name       :string
#  google_id  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
