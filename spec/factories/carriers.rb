# frozen_string_literal: true

FactoryBot.define do
  factory :carrier do
    name { 'Hapag Lloyd' }
  end
end

# == Schema Information
#
# Table name: carriers
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
