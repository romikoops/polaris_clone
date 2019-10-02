# frozen_string_literal: true

FactoryBot.define do
  factory :hub_trucking do
    association :hub
    association :trucking_pricing
    association :trucking_destination
  end
end

# == Schema Information
#
# Table name: hub_truckings
#
#  id                      :bigint           not null, primary key
#  hub_id                  :integer
#  trucking_destination_id :integer
#  trucking_pricing_id     :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
