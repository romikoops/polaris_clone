# frozen_string_literal: true

FactoryBot.define do
  factory :stop do
    association :hub
    association :itinerary
    sequence(:index) { |n| n }
  end
end

# == Schema Information
#
# Table name: stops
#
#  id           :bigint(8)        not null, primary key
#  hub_id       :integer
#  itinerary_id :integer
#  index        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
