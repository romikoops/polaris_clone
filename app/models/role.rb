# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users
end

# == Schema Information
#
# Table name: roles
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
