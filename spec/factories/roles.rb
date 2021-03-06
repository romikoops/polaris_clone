# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { "shipper" }
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
