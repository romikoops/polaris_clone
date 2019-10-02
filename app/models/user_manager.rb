# frozen_string_literal: true

class UserManager < ApplicationRecord
end

# == Schema Information
#
# Table name: user_managers
#
#  id         :bigint           not null, primary key
#  manager_id :integer
#  user_id    :integer
#  section    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
