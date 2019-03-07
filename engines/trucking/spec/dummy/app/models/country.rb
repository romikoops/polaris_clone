# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :addresses
  has_many :nexuses
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  code       :string
#  flag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
