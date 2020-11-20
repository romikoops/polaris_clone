# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle do
    name { "standard" }
    mode_of_transport { "ocean" }
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint           not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
