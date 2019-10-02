# frozen_string_literal: true

module Legacy
  class Role < ApplicationRecord
    self.table_name = 'roles'
    has_many :users, class_name: 'Legacy::User'
  end
end

# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
