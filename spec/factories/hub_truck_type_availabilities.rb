# frozen_string_literal: true

FactoryBot.define do
  factory :hub_truck_type_availability do
    hub { :association }
    truck_type_availability { :association }
  end
end

# == Schema Information
#
# Table name: hub_truck_type_availabilities
#
#  id                         :bigint(8)        not null, primary key
#  hub_id                     :integer
#  truck_type_availability_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
