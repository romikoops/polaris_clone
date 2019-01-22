# frozen_string_literal: true

FactoryBot.define do
  factory :truck_type_availability do
    load_type  { 'cargo_item' }
    carriage   { 'pre' }
    truck_type { 'default' }
  end
end

# == Schema Information
#
# Table name: truck_type_availabilities
#
#  id         :bigint(8)        not null, primary key
#  load_type  :string
#  carriage   :string
#  truck_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
