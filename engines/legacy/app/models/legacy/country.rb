# frozen_string_literal: true

module Legacy
  class Country < ApplicationRecord
    self.table_name = 'countries'
    has_many :addresses, class_name: 'Legacy::Address'
    has_many :nexuses
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  name       :string
#  code       :string
#  flag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
